# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

locals {
  hosted_zones = {
    "massopen.cloud"             = "Top-level MOC domain"
    "int.massopen.cloud"         = "Internal MOC systems"
    "ocp.massopen.cloud"         = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
    "hcp.oac.massopen.cloud"     = "For hosted control plane external services"
    "hcp-int.oac.massopen.cloud" = "For hosted control plane internal services"
  }
}

resource "aws_route53_zone" "this" {
  for_each      = local.hosted_zones
  name          = each.key
  comment       = each.value
  force_destroy = true
}

resource "aws_route53_record" "hcp-ext-wildcard" {
  zone_id = aws_route53_zone.this["hcp.oac.massopen.cloud"].zone_id
  name    = "*.hcp.oac.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["129.10.5.103"]
}

resource "aws_route53_record" "hcp-int-wildcard" {
  zone_id = aws_route53_zone.this["hcp-int.oac.massopen.cloud"].zone_id
  name    = "*.hcp-int.oac.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.9.10"]
}
