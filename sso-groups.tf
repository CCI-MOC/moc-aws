# -----------------------------------------------------------------------------
# IAM Identity Center – Groups
# -----------------------------------------------------------------------------

locals {
  sso_groups = {
    "moc-aws-admins"    = "Users with admin access to AWS.",
    "moc-aws-operators" = "Provides SystemAdministrator access to AWS (https://docs.aws.amazon.com/aws-managed-policy/latest/reference/SystemAdministrator.html)",
  }
}

resource "aws_identitystore_group" "this" {
  for_each          = local.sso_groups
  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value
}
