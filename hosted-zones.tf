# -----------------------------------------------------------------------------
# Route53 – Hosted zones
# -----------------------------------------------------------------------------

locals {
  hosted_zones = {
    "massopen.cloud"                         = "Top-level MOC domain"
    "int.massopen.cloud"                     = "Internal MOC systems"
    "ocp.massopen.cloud"                     = "For MOCs OpenShift clusters. Initially they will host the NIST cluster."
    "hcp.oac.massopen.cloud"                 = "For prod hosted control plane external services"
    "hcp-int.oac.massopen.cloud"             = "For prod hosted control plane internal services"
    "hcp.oac.int.massopen.cloud"             = "For dev hosted control plane external services"
    "hcp-int.oac.int.massopen.cloud"         = "For dev hosted control plane internal services"
    "nist.int.massopen.cloud"                = "For NIST 800-171 compliant clusters"
    "hcp.nist.int.massopen.cloud"            = "For compliant-dev-infra hosted cluster ingress"
    "hcp-int.nist.int.massopen.cloud"        = "For compliant-dev-infra hosted control plane services"
    "dizzy-int.int.massopen.cloud"           = "For dizzy hcp internal services"
    "dizzy-ext.int.massopen.cloud"           = "For dizzy hcp external services"
    "hcp.bu-ist-demo.int.massopen.cloud"     = "For BU IST demo infra hosted cluster external services"
    "hcp-int.bu-ist-demo.int.massopen.cloud" = "For BU IST demo infra hosted cluster internal services"
  }
}

resource "aws_route53_zone" "this" {
  for_each      = local.hosted_zones
  name          = each.key
  comment       = each.value
  force_destroy = true
}

resource "aws_route53_record" "dizzy-ext-wildcard" {
  zone_id = aws_route53_zone.this["dizzy-ext.int.massopen.cloud"].zone_id
  name    = "*.dizzy-ext.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["129.10.5.107"]
}

resource "aws_route53_record" "dizzy-int-wildcard" {
  zone_id = aws_route53_zone.this["dizzy-int.int.massopen.cloud"].zone_id
  name    = "*.dizzy-int.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.23.10"]
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

# compliant-dev-infra (MOC-issues #754). It replaces nist-dev-infra, which
# was removed on 2026-10-28, on the same networks and VIPs.
resource "aws_route53_record" "compliant-dev-infra-api" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "api.compliant-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.11"]
}

resource "aws_route53_record" "compliant-dev-infra-api-int" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "api-int.compliant-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.11"]
}

resource "aws_route53_record" "compliant-dev-infra-apps-wildcard" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "*.apps.compliant-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.12"]
}

# The hub's object storage proxy (object-storage-proxy chart), in front of
# the FlashBlade's S3 endpoint. The address is the proxy Service's fixed
# cluster IP, so the name resolves only from inside the cluster, as for the
# oac clusters' s3 names.
resource "aws_route53_record" "compliant-dev-infra-s3" {
  zone_id = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name    = "s3.compliant-dev-infra.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["172.30.0.53"]
}

# Delegation. It first went live after nist-dev-infra's records, so the
# zone was never empty; they have since been replaced by the records above.
resource "aws_route53_record" "nist-int-delegation" {
  zone_id = aws_route53_zone.this["int.massopen.cloud"].zone_id
  name    = "nist.int.massopen.cloud"
  type    = "NS"
  ttl     = 300
  # name_servers lacks the trailing dot, but Route53 always stores/returns NS
  # values in canonical FQDN form; without this the plan flip-flops forever.
  records = [for ns in aws_route53_zone.this["nist.int.massopen.cloud"].name_servers : "${ns}."]
}

# The nist hub's hosted clusters. external-dns on the hub writes each
# cluster's API and ingress records; cert-manager writes its challenges.
# Both zones are new names, so delegating them while empty breaks nothing.
resource "aws_route53_record" "hcp-nist-delegation" {
  for_each = toset(["hcp.nist.int.massopen.cloud", "hcp-int.nist.int.massopen.cloud"])
  zone_id  = aws_route53_zone.this["nist.int.massopen.cloud"].zone_id
  name     = each.value
  type     = "NS"
  ttl      = 300
  records  = [for ns in aws_route53_zone.this[each.value].name_servers : "${ns}."]
}

# BU IST demo infra's hosted-cluster DNS zones.
resource "aws_route53_record" "bu_ist_demo_infra_delegation" {
  for_each = toset(["hcp.bu-ist-demo.int.massopen.cloud", "hcp-int.bu-ist-demo.int.massopen.cloud"])
  zone_id  = aws_route53_zone.this["int.massopen.cloud"].zone_id
  name     = each.value
  type     = "NS"
  ttl      = 300
  records  = [for ns in aws_route53_zone.this[each.value].name_servers : "${ns}."]
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

# The workload clusters' base domain, as on the oac hubs. The agents' install
# checks look up api and api-int.<cluster>.hcp.nist.int.massopen.cloud; nothing
# connects to them. external-dns's *.apps.<cluster> records are more specific
# and still win.
resource "aws_route53_record" "hcp-nist-wildcard" {
  zone_id = aws_route53_zone.this["hcp.nist.int.massopen.cloud"].zone_id
  name    = "*.hcp.nist.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.19.10"]
}

resource "aws_route53_record" "hcp-bu-ist-demo-int-wildcard" {
  zone_id = aws_route53_zone.this["hcp-int.bu-ist-demo.int.massopen.cloud"].zone_id
  name    = "*.hcp-int.bu-ist-demo.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["10.20.27.10"]
}

resource "aws_route53_record" "hcp-bu-ist-demo-wildcard" {
  zone_id = aws_route53_zone.this["hcp.bu-ist-demo.int.massopen.cloud"].zone_id
  name    = "*.hcp.bu-ist-demo.int.massopen.cloud"
  type    = "A"
  ttl     = 300
  records = ["129.10.5.111"]
}
