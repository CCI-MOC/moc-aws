# -----------------------------------------------------------------------------
# S3 – Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "osac_terraform_state" {
  bucket = "osac-terraform-state"
}

resource "aws_s3_bucket_public_access_block" "osac_terraform_state" {
  bucket = aws_s3_bucket.osac_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
