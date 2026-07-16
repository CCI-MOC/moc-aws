terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws, aws.secrets]
    }
  }
}

resource "aws_iam_user" "this" {
  name = var.name
}

resource "aws_iam_user_login_profile" "this" {
  count                   = var.allow_change_password ? 1 : 0
  user                    = aws_iam_user.this.name
  password_reset_required = true

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_user_policy_attachment" "change_password" {
  count      = var.allow_change_password ? 1 : 0
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each   = toset(var.policies)
  user       = aws_iam_user.this.name
  policy_arn = each.value
}

resource "aws_secretsmanager_secret" "console_password" {
  provider                = aws.secrets
  count                   = var.allow_change_password ? 1 : 0
  name                    = "wasabi-user/${var.name}/console"
  recovery_window_in_days = var.secret_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "console_password" {
  provider  = aws.secrets
  count     = var.allow_change_password ? 1 : 0
  secret_id = aws_secretsmanager_secret.console_password[0].id
  secret_string = jsonencode({
    password = aws_iam_user_login_profile.this[0].password
  })
}
