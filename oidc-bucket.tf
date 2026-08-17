# -----------------------------------------------------------------------------
# S3 – Shared OIDC discovery bucket for OAC OpenShift clusters
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "oac_oidc" {
  bucket = "oac-clusters-oidc"
}

resource "aws_s3_bucket_public_access_block" "oac_oidc" {
  bucket = aws_s3_bucket.oac_oidc.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "oac_oidc_bucket" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.oac_oidc.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "oac_oidc" {
  bucket = aws_s3_bucket.oac_oidc.id
  policy = data.aws_iam_policy_document.oac_oidc_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.oac_oidc]
}
