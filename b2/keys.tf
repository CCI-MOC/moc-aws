# -----------------------------------------------------------------------------
# Backblaze B2 – Application Keys
# -----------------------------------------------------------------------------

locals {
  b2_caps_read_write = [
    "listAllBucketNames",
    "listBuckets",
    "readBuckets",
    "listFiles",
    "readFiles",
    "shareFiles",
    "writeFiles",
    "deleteFiles",
    "readBucketEncryption",
    "writeBucketEncryption",
    "readBucketLogging",
    "writeBucketLogging",
    "readBucketReplications",
    "writeBucketReplications",
    "readBucketNotifications",
    "writeBucketNotifications",
    "readBucketLifecycleRules",
    "writeBucketLifecycleRules",
  ]

  b2_caps_admin = [
    "listKeys",
    "writeKeys",
    "deleteKeys",
    "listBuckets",
    "writeBuckets",
    "deleteBuckets",
    "readBuckets",
    "listFiles",
    "readFiles",
    "shareFiles",
    "writeFiles",
    "deleteFiles",
    "readBucketEncryption",
    "writeBucketEncryption",
    "readBucketLogging",
    "writeBucketLogging",
    "readBucketReplications",
    "writeBucketReplications",
    "readBucketNotifications",
    "writeBucketNotifications",
    "bypassGovernance",
    "readBucketRetentions",
    "writeBucketRetentions",
    "readFileRetentions",
    "writeFileRetentions",
    "readFileLegalHolds",
    "writeFileLegalHolds",
    "readBucketLifecycleRules",
    "writeBucketLifecycleRules",
  ]

  b2_caps_read_only = [
    "listAllBucketNames",
    "listBuckets",
    "readBuckets",
    "listFiles",
    "readFiles",
    "shareFiles",
    "readBucketEncryption",
    "readBucketLogging",
    "readBucketReplications",
    "readBucketNotifications",
    "readBucketLifecycleRules",
  ]

  b2_keys = {
    "github-tf-workflow" = {
      capabilities = local.b2_caps_admin
    }
  }
}

module "key" {
  for_each     = local.b2_keys
  source       = "./modules/application-key"
  key_name     = each.key
  capabilities = each.value.capabilities
  bucket_ids   = try(each.value.bucket_ids, null)
  name_prefix  = try(each.value.name_prefix, null)
  description  = try(each.value.description, "")
}
