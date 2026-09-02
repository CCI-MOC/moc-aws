# -----------------------------------------------------------------------------
# GitHub OIDC – Reduced-privilege roles for other repositories
# -----------------------------------------------------------------------------
#
# Each entry in var.consumer_repos gets its own IAM role, assumable only by the
# named repository, with inline policies scoping SecretsManager and moc-tf-state
# access. The shared OIDC provider (main.tf) is reused.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "github_actions_consumer_assume_role" {
  for_each = var.consumer_repos

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Default to the plain "repo:<org>/<repo>:*" subject. Repos whose OIDC
      # subject uses GitHub's immutable IDs must override this via
      # subject_claims, because the plain form cannot match the immutable one.
      # Find the exact prefix (then append ":*") with:
      #   gh api repos/${each.value.repository}/actions/oidc/customization/sub --jq .sub_claim_prefix
      values = coalesce(each.value.subject_claims, ["repo:${each.value.repository}:*"])
    }
  }
}

resource "aws_iam_role" "github_actions_consumer" {
  for_each = var.consumer_repos

  name               = "github-actions-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_consumer_assume_role[each.key].json
}

locals {
  # S3 object ARNs each consumer role may read/write: the default-workspace
  # state object and its lockfile, plus the named-workspace (env:/*/...) forms,
  # for every key in state_keys. The .tflock objects are required because the
  # backend uses use_lockfile = true.
  consumer_state_object_arns = {
    for k, v in var.consumer_repos : k => flatten([
      for key in v.state_keys : [
        "arn:aws:s3:::${var.state_bucket}/${key}",
        "arn:aws:s3:::${var.state_bucket}/${key}.tflock",
        "arn:aws:s3:::${var.state_bucket}/env:/*/${key}",
        "arn:aws:s3:::${var.state_bucket}/env:/*/${key}.tflock",
      ]
    ])
  }

  # ListBucket s3:prefix values: each key (and its workspace/lockfile children
  # via the trailing *) plus env:/* so `tofu workspace list` can enumerate.
  consumer_state_list_prefixes = {
    for k, v in var.consumer_repos : k => concat(
      [for key in v.state_keys : "${key}*"],
      ["env:/*"],
    )
  }
}

data "aws_iam_policy_document" "github_actions_consumer_state" {
  for_each = var.consumer_repos

  statement {
    sid       = "StateObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = local.consumer_state_object_arns[each.key]
  }

  statement {
    sid       = "StateBucketList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = local.consumer_state_list_prefixes[each.key]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_consumer_state" {
  for_each = var.consumer_repos

  name   = "state-access"
  role   = aws_iam_role.github_actions_consumer[each.key].name
  policy = data.aws_iam_policy_document.github_actions_consumer_state[each.key].json
}

locals {
  # Secret ARNs carry a random 6-char suffix, so each name prefix is matched as
  # secret:<prefix>*.
  consumer_secret_arn_base = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:"

  consumer_ro_secret_arns = {
    for k, v in var.consumer_repos :
    k => [for p in v.ro_secret_prefixes : "${local.consumer_secret_arn_base}${p}*"]
  }

  consumer_rw_secret_arns = {
    for k, v in var.consumer_repos :
    k => [for p in v.rw_secret_prefixes : "${local.consumer_secret_arn_base}${p}*"]
  }

  # Only repos that declare at least one prefix get a secrets-access policy.
  consumer_repos_with_secrets = {
    for k, v in var.consumer_repos : k => v
    if length(v.ro_secret_prefixes) > 0 || length(v.rw_secret_prefixes) > 0
  }
}

data "aws_iam_policy_document" "github_actions_consumer_secrets" {
  for_each = local.consumer_repos_with_secrets

  dynamic "statement" {
    for_each = length(each.value.ro_secret_prefixes) > 0 ? [1] : []
    content {
      sid    = "SecretsReadOnly"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:ListSecretVersionIds",
      ]
      resources = local.consumer_ro_secret_arns[each.key]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.rw_secret_prefixes) > 0 ? [1] : []
    content {
      sid    = "SecretsReadWrite"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:CreateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:DeleteSecret",
        "secretsmanager:RestoreSecret",
      ]
      resources = local.consumer_rw_secret_arns[each.key]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_consumer_secrets" {
  for_each = local.consumer_repos_with_secrets

  name   = "secrets-access"
  role   = aws_iam_role.github_actions_consumer[each.key].name
  policy = data.aws_iam_policy_document.github_actions_consumer_secrets[each.key].json
}
