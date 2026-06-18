# -----------------------------------------------------------------------------
# GitHub OIDC – Provider and IAM role
# -----------------------------------------------------------------------------

# Define a policy that lets Github actions acquire AWS credentials using OIDC.

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
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

resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# This policy prevents the github identity form performing potentially
# dangerous actions (those that impact the entire organization or that otherwise
# have a large blast radius).
data "aws_iam_policy_document" "github_actions_deny_dangerous" {
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

resource "aws_iam_role_policy" "github_actions_deny_dangerous" {
  name   = "github-actions-deny-dangerous"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.github_actions_deny_dangerous.json
}
