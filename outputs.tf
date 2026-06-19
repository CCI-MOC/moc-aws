# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "sso_instance_arn" {
  value = local.sso_instance_arn
}

output "identity_store_id" {
  value = local.identity_store_id
}
output "github_actions_admin_role_arn" {
  value = module.oidc.github_actions_admin_role_arn
}

output "github_actions_dns_role_arn" {
  value = module.oidc.github_actions_dns_role_arn
}
