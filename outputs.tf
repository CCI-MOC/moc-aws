# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "sso_instance_arn" {
  value       = local.sso_instance_arn
  description = "ARN of our AWS Identity Center instance"
}

output "identity_store_id" {
  value       = local.identity_store_id
  description = "ARN of the Identity Store instance associated with our IAM Identity Center instance. Used when creating SSO users and groups."
}
output "github_actions_admin_role_arn" {
  value       = module.github-oidc.github_actions_admin_role_arn
  description = "Set AWS_ROLE_ARN to this value for GitHub workflows that require administrative access"
}

output "github_actions_dns_role_arn" {
  value       = module.github-oidc.github_actions_dns_role_arn
  description = "Set AWS_ROLE_ARN to this value for GitHub workflows that interact only with Route53"
}

output "iam_user_access_keys" {
  value       = { for name, user in module.iam_user : name => user.access_keys }
  description = "Show names, access key ids, and corresponding secret ARN for all managed iam users"
}

output "wasabi_console_secrets" {
  value       = module.wasabi.console_secrets
  description = "Secrets Manager secrets containing initial console passwords for Wasabi users"
}
