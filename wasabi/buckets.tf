# -----------------------------------------------------------------------------
# Wasabi – S3 Buckets
# -----------------------------------------------------------------------------

locals {
  wasabi_buckets = {
    "nerc-loki-backup-bu"    = {}
    "nerc-metrics-backup-bu" = {}
  }
}

module "bucket" {
  for_each = local.wasabi_buckets
  source   = "./modules/bucket"
  name     = each.key
  policies = try(each.value.policies, [])

  providers = {
    aws = aws.wasabi
  }
}
