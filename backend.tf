# -----------------------------------------------------------------------------
# Backend -- Terraform/OpenTofu state storage
# -----------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket = "moc-tf-state"
    key    = "moc-aws"
    region = "us-east-1"
  }
}
