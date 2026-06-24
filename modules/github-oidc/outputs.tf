output "github_actions_admin_role_arn" {
  value = aws_iam_role.github_actions_admin.arn
}

output "github_actions_dns_role_arn" {
  value = aws_iam_role.github_actions_dns.arn
}
