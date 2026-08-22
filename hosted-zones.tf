# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

locals {
  hosted_zones = {
    "massopen.cloud"     = "Top-level MOC domain"
    "int.massopen.cloud" = "Internal MOC systems"
    "ocp.massopen.cloud" = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
  }
}

resource "aws_route53_zone" "this" {
  for_each      = local.hosted_zones
  name          = each.key
  comment       = each.value
  force_destroy = true
}
