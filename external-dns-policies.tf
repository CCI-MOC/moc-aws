# -----------------------------------------------------------------------------
# Route53 zone policies for external-dns
# -----------------------------------------------------------------------------

module "external_dns_policy_hcp_oac_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "hcp.oac.int.massopen.cloud"
  policy_name        = "external-dns-hcp-oac-int-massopen-cloud"
  policy_description = "allow external-dns on oac-dev-infra to manage records in hcp.oac.int.massopen.cloud"
}

module "external_dns_policy_hcp_int_oac_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "hcp-int.oac.int.massopen.cloud"
  policy_name        = "external-dns-hcp-int-oac-int-massopen-cloud"
  policy_description = "allow external-dns on oac-dev-infra to manage records in hcp-int.oac.int.massopen.cloud"
}

module "external_dns_policy_hcp_oac_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_arn           = aws_route53_zone.this["hcp.oac.massopen.cloud"].arn
  policy_name        = "external-dns-hcp-oac-massopen-cloud"
  policy_description = "allow external-dns on oac-prod-infra to manage records in hcp.oac.massopen.cloud"
}

module "external_dns_policy_hcp_int_oac_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_arn           = aws_route53_zone.this["hcp-int.oac.massopen.cloud"].arn
  policy_name        = "external-dns-hcp-int-oac-massopen-cloud"
  policy_description = "allow external-dns on oac-prod-infra to manage records in hcp-int.oac.massopen.cloud"
}

module "external_dns_policy_hcp_nist_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_arn           = aws_route53_zone.this["hcp.nist.int.massopen.cloud"].arn
  policy_name        = "external-dns-hcp-nist-int-massopen-cloud"
  policy_description = "allow external-dns on nist-dev-infra to manage records in hcp.nist.int.massopen.cloud"
}

module "external_dns_policy_hcp_int_nist_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_arn           = aws_route53_zone.this["hcp-int.nist.int.massopen.cloud"].arn
  policy_name        = "external-dns-hcp-int-nist-int-massopen-cloud"
  policy_description = "allow external-dns on nist-dev-infra to manage records in hcp-int.nist.int.massopen.cloud"
}
