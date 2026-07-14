# -----------------------------------------------------------------------------
# Wasabi – IAM Policies
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "nerc_wasabi_backup_write_no_delete" {
  statement {
    sid    = "BackupBucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      module.bucket["nerc-metrics-backup-bu"].arn,
      module.bucket["nerc-loki-backup-bu"].arn,
    ]
  }

  statement {
    sid    = "BackupObjectWriteNoDelete"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "${module.bucket["nerc-metrics-backup-bu"].arn}/*",
      "${module.bucket["nerc-loki-backup-bu"].arn}/*",
    ]
  }
}

resource "aws_iam_policy" "nerc_wasabi_backup_write_no_delete" {
  provider = aws.wasabi
  name     = "nerc-wasabi-backup-write-no-delete"
  policy   = data.aws_iam_policy_document.nerc_wasabi_backup_write_no_delete.json
}
