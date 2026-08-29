# -----------------------------------------------------------------------------
# Route53 zone policies for external-dns
# -----------------------------------------------------------------------------

module "external_dns_policy_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "int.massopen.cloud"
  policy_name        = "external-dns-int-massopen-cloud"
  policy_description = "allow external-dns on oac-dev-infra to manage records in int.massopen.cloud"
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
