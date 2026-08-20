# -----------------------------------------------------------------------------
# OpenShift OIDC – IAM role for External Secrets Operator
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "eso_assume_role" {
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
      values   = ["system:serviceaccount:external-secrets:external-secrets-sa"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "eso-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

data "aws_iam_policy_document" "eso_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:cluster/${var.cluster_name}/*",
    ]
  }

  dynamic "statement" {
    for_each = length(var.eso_writable_secret_prefixes) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "secretsmanager:CreateSecret",
        "secretsmanager:DeleteResourcePolicy",
        "secretsmanager:PutSecretValue",
        "secretsmanager:TagResource",
      ]
      resources = [
        for prefix in var.eso_writable_secret_prefixes :
        "arn:aws:secretsmanager:*:*:secret:${prefix}*"
      ]
    }
  }
}

resource "aws_iam_policy" "eso_secrets_manager" {
  name   = "eso-${var.cluster_name}-secrets-manager"
  policy = data.aws_iam_policy_document.eso_secrets_manager.json
}

resource "aws_iam_role_policy_attachment" "eso_secrets_manager" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso_secrets_manager.arn
}
