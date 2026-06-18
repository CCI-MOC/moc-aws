# -----------------------------------------------------------------------------
# GitHub OIDC – IAM role for CCI-MOC/moc-dns
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "github_actions_dns_assume_role" {
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
      values   = ["repo:CCI-MOC/moc-dns:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_dns" {
  name               = "github-actions-dns"
  assume_role_policy = data.aws_iam_policy_document.github_actions_dns_assume_role.json
}

data "aws_iam_policy_document" "github_actions_dns_permissions" {
  statement {
    sid    = "AllowRoute53RecordManagement"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_dns_permissions" {
  name   = "github-actions-dns-permissions"
  role   = aws_iam_role.github_actions_dns.name
  policy = data.aws_iam_policy_document.github_actions_dns_permissions.json
}
