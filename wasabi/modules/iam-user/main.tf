terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
