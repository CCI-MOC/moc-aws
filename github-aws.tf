# -----------------------------------------------------------------------------
# GitHub OIDC – IAM role for CCI-MOC/moc-aws
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "github_actions_admin_assume_role" {
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
      values   = ["repo:CCI-MOC/moc-aws:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_admin" {
  name               = "github-actions-admin"
  assume_role_policy = data.aws_iam_policy_document.github_actions_admin_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# This policy prevents the github identity form performing potentially
# dangerous actions (those that impact the entire organization or that otherwise
# have a large blast radius).
data "aws_iam_policy_document" "github_actions_admin_deny_dangerous" {
  statement {
    sid    = "DenyDangerousActions"
    effect = "Deny"

    actions = [
      "organizations:LeaveOrganization",
      "account:CloseAccount",
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
      "config:DeleteConfigurationRecorder",
      "config:StopConfigurationRecorder",
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:AttachUserPolicy",
      "iam:PutUserPolicy",
      "aws-marketplace:Subscribe",
      "aws-marketplace:CreatePrivateMarketplace",
      "savingsplans:CreateSavingsPlan",
      "ce:UpdatePreferences",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_admin_deny_dangerous" {
  name   = "github-actions-admin-deny-dangerous"
  role   = aws_iam_role.github_actions_admin.name
  policy = data.aws_iam_policy_document.github_actions_admin_deny_dangerous.json
}
