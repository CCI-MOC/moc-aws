# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

resource "aws_route53_zone" "massopen_cloud" {
  name    = "massopen.cloud"
  comment = "Top-level MOC domain"
}

resource "aws_route53_zone" "int_massopen_cloud" {
  name    = "int.massopen.cloud"
  comment = "Internal MOC systems"
}

resource "aws_route53_zone" "svc_massopen_cloud" {
  name    = "svc.massopen.cloud"
  comment = "Public facing services"
}

resource "aws_route53_zone" "box_massopen_cloud" {
  name    = "box.massopen.cloud"
  comment = "Used by the OSAC development environment"
}

resource "aws_route53_zone" "ocp_massopen_cloud" {
  name    = "ocp.massopen.cloud"
  comment = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
}

resource "aws_route53_zone" "osac_integration_svc_massopen_cloud" {
  name    = "osac-integration.svc.massopen.cloud"
  comment = "Used for OSAC integration tests"
}
