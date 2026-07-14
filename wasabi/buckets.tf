# -----------------------------------------------------------------------------
# Wasabi – S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "nerc_loki_backup_bu" {
  provider = aws.wasabi
  bucket   = "nerc-loki-backup-bu"

  tags = {
    managed-by = "moc-aws"
  }
}

resource "aws_s3_bucket" "nerc_metrics_backup_bu" {
  provider = aws.wasabi
  bucket   = "nerc-metrics-backup-bu"

  tags = {
    managed-by = "moc-aws"
  }
}
