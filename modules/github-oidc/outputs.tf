output "github_actions_admin_role_arn" {
  description = "ARN of the IAM role for GitHub Actions with admin permissions"
  value       = aws_iam_role.github_actions_admin.arn
}

output "github_actions_dns_role_arn" {
  description = "ARN of the IAM role for GitHub Actions with DNS management permissions"
  value       = aws_iam_role.github_actions_dns.arn
}
