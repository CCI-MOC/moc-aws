# -----------------------------------------------------------------------------
# Backblaze B2 – Buckets
# -----------------------------------------------------------------------------

locals {
  b2_buckets = {
    "esi-leases"                      = {}
    "nerc-invoicing"                  = {}
    "nerc-invoicing-iceberg"          = {}
    "nerc-ocp-barcelona-metrics"      = {}
    "nerc-ocp-edu-metrics"            = {}
    "nerc-ocp-edu-metrics-hf"         = {}
    "nerc-ocp-test"                   = {}
    "openshift-metrics"               = {}
    "openshift-metrics-backup-source" = {}
    "openshift-metrics-hf"            = {}
  }
}

module "bucket" {
  for_each    = local.b2_buckets
  source      = "./modules/bucket"
  name        = each.key
  bucket_type = try(each.value.bucket_type, "allPrivate")
}
