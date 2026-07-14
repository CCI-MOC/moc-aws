# -----------------------------------------------------------------------------
# Wasabi – IAM Policies
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "nerc_wasabi_backup_write_no_delete" {
  provider = aws.wasabi
  name     = "nerc-wasabi-backup-write-no-delete"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BackupBucketList"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          aws_s3_bucket.nerc_metrics_backup_bu.arn,
          aws_s3_bucket.nerc_loki_backup_bu.arn,
        ]
      },
      {
        Sid    = "BackupObjectWriteNoDelete"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.nerc_metrics_backup_bu.arn}/*",
          "${aws_s3_bucket.nerc_loki_backup_bu.arn}/*",
        ]
      },
    ]
  })
}
