resource "aws_s3_bucket" "this" {
  bucket = var.name
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.allow_public_access ? 0 : 1
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.storage_class != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-${lower(var.storage_class)}"
    status = "Enabled"

    filter {}

    transition {
      days          = 0
      storage_class = var.storage_class
    }
  }
}
