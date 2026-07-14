terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = {
    managed-by = var.managed_by
  }
}

data "aws_iam_policy_document" "this" {
  count                   = length(var.policies) > 0 ? 1 : 0
  source_policy_documents = var.policies
}

resource "aws_s3_bucket_policy" "this" {
  count  = length(var.policies) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}
