# -----------------------------------------------------------------------------
# Data sources
# -----------------------------------------------------------------------------

# This performs a query against AWS to discover information about
# AWS SSO instances.
data "aws_ssoadmin_instances" "this" {}

# Expose the discovered sso instance ARN and identify store id in loca
# variables.
locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}
