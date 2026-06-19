# -----------------------------------------------------------------------------
# Backend -- Terraform/OpenTofu state storage
# -----------------------------------------------------------------------------

# This stores state in the `moc-tf-state` bucket in an object named `moc-aws`.
terraform {
  backend "s3" {
    bucket = "moc-tf-state"
    key    = "moc-aws"
    region = "us-east-1"
  }
}
