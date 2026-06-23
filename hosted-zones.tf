# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

locals {
  hosted_zones = {
    "massopen.cloud"                      = "Top-level MOC domain"
    "int.massopen.cloud"                  = "Internal MOC systems"
    "svc.massopen.cloud"                  = "Public facing services"
    "box.massopen.cloud"                  = "Used by the OSAC development environment"
    "ocp.massopen.cloud"                  = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
    "osac-integration.svc.massopen.cloud" = "Used for OSAC integration tests"
  }
}

resource "aws_route53_zone" "this" {
  for_each = local.hosted_zones
  name     = each.key
  comment  = each.value
}
