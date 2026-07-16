output "name" {
  description = "The IAM user name"
  value       = aws_iam_user.this.name
}

output "password" {
  description = "The initial console password (only available on first apply)"
  value       = var.allow_change_password ? aws_iam_user_login_profile.this[0].password : null
  sensitive   = true
}
