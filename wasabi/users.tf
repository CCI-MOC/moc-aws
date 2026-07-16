# -----------------------------------------------------------------------------
# Wasabi – IAM Users
# -----------------------------------------------------------------------------

locals {
  wasabi_users = {
    "nerc-backup-wasabi" = {
      policies = [aws_iam_policy.nerc_wasabi_backup_write_no_delete.arn]
    }
    "tschwesi" = {
      allow_change_password = true
    }
    "lars" = {
      allow_change_password = true
    }
  }
}

module "user" {
  for_each              = local.wasabi_users
  source                = "./modules/iam-user"
  name                  = each.key
  allow_change_password = try(each.value.allow_change_password, false)
  policies              = try(each.value.policies, [])

  providers = {
    aws         = aws.wasabi
    aws.secrets = aws
  }
}
