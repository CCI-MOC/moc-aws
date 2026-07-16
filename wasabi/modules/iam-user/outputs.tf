output "name" {
  description = "The IAM user name"
  value       = aws_iam_user.this.name
}

output "console_secret" {
  description = "Secrets Manager secret containing the initial console password"
  value = var.allow_change_password ? {
    arn  = aws_secretsmanager_secret.console_password[0].arn
    name = aws_secretsmanager_secret.console_password[0].name
  } : null
}
