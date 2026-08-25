# -----------------------------------------------------------------------------
# OpenShift OIDC – IAM roles for arbitrary service accounts
# -----------------------------------------------------------------------------

locals {
  # Trust/role instances keyed on the static fields only. Policy ARNs may be
  # known only after apply (e.g. sourced from another module), which would
  # otherwise make the whole for_each map unknown at plan time.
  service_account_role_trusts = {
    for key, cfg in var.service_account_roles : key => {
      namespace       = cfg.namespace
      service_account = cfg.service_account
    }
  }

  # Flatten service_account_roles into one policy attachment per (role, arn)
  # pair so we can drive a single aws_iam_role_policy_attachment resource. Keys
  # use the list index (static) rather than the ARN (may be unknown at plan).
  service_account_role_policy_attachments = merge([
    for key, cfg in var.service_account_roles : {
      for idx, arn in cfg.policy_arns :
      "${key}:${idx}" => {
        role_key   = key
        policy_arn = arn
      }
    }
  ]...)
}

data "aws_iam_policy_document" "service_account_assume_role" {
  for_each = local.service_account_role_trusts

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
  }
}

resource "aws_iam_role" "service_account" {
  for_each = local.service_account_role_trusts

  name               = "${each.key}-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role[each.key].json
}

resource "aws_iam_role_policy_attachment" "service_account" {
  for_each = local.service_account_role_policy_attachments

  role       = aws_iam_role.service_account[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
