# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

locals {
  hosted_zones = {
    "massopen.cloud"                  = "Top-level MOC domain"
    "int.massopen.cloud"              = "Internal MOC systems"
    "ocp.massopen.cloud"              = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
    "hcp.oac.massopen.cloud"          = "For prod hosted control plane external services"
    "hcp-int.oac.massopen.cloud"      = "For prod hosted control plane internal services"
    "hcp.oac.int.massopen.cloud"      = "For dev hosted control plane external services"
    "hcp-int.oac.int.massopen.cloud"  = "For dev hosted control plane internal services"
    "nist.int.massopen.cloud"         = "For NIST 800-171 compliant clusters"
    "hcp.nist.int.massopen.cloud"     = "For nist-dev-infra hosted cluster ingress"
    "hcp-int.nist.int.massopen.cloud" = "For nist-dev-infra hosted control plane services"
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

resource "aws_route53_record" "hcp-dev-ext-wildcard" {
  zone_id = aws_route53_zone.this["hcp.oac.int.massopen.cloud"].zone_id
  name    = "*.hcp.oac.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["129.10.5.101"]
}

resource "aws_route53_record" "hcp-dev-workload2-apps-wildcard" {
  zone_id = aws_route53_zone.this["hcp.oac.int.massopen.cloud"].zone_id
  name    = "*.apps.oac-dev-workload2.hcp.oac.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.15.200"]
}

resource "aws_route53_record" "hcp-dev-int-wildcard" {
  zone_id = aws_route53_zone.this["hcp-int.oac.int.massopen.cloud"].zone_id
  name    = "*.hcp-int.oac.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.3.10"]
}

# nist.int.massopen.cloud is delegated from int.massopen.cloud. The hub's
# records were first created by hand in int.massopen.cloud; they are copied
# here so the names keep resolving once the delegation is live.
resource "aws_route53_record" "nist-dev-infra-api" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "api.nist-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.11"]
}

resource "aws_route53_record" "nist-dev-infra-api-int" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "api-int.nist-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.11"]
}

resource "aws_route53_record" "nist-dev-infra-apps-wildcard" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "*.apps.nist-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.12"]
}

# Delegation. Created after the records above, so the new zone is never
# live while empty.
resource "aws_route53_record" "nist-int-delegation" {
  zone_id = aws_route53_zone.this["int.massopen.cloud"].zone_id
  name    = "nist.int.massopen.cloud"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.this["nist.int.massopen.cloud"].name_servers

  depends_on = [
    aws_route53_record.nist-dev-infra-api,
    aws_route53_record.nist-dev-infra-api-int,
    aws_route53_record.nist-dev-infra-apps-wildcard,
  ]
}

# nist-dev-infra's hosted clusters. external-dns on the hub writes each
# cluster's API and ingress records; cert-manager writes its challenges.
# Both zones are new names, so delegating them while empty breaks nothing.
resource "aws_route53_record" "hcp-nist-delegation" {
  for_each = toset(["hcp.nist.int.massopen.cloud", "hcp-int.nist.int.massopen.cloud"])
  zone_id  = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name     = each.value
  type     = "NS"
  ttl      = 300
  records  = aws_route53_zone.this[each.value].name_servers
}

# The hosted control planes' Ignition, Konnectivity and OAuth routes, served by
# the hub's hosted-clusters router (hcp-config's MetalLB address).
resource "aws_route53_record" "hcp-nist-int-wildcard" {
  zone_id = aws_route53_zone.this["hcp-int.nist.int.massopen.cloud"].zone_id
  name    = "*.hcp-int.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.10"]
}
