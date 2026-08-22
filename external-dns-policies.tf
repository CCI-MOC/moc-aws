# -----------------------------------------------------------------------------
# Route53 zone policies for external-dns
# -----------------------------------------------------------------------------

module "external_dns_policy_int_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "int.massopen.cloud"
  policy_name        = "external-dns-int-massopen-cloud"
  policy_description = "allow external-dns on oac-dev-infra to manage records in int.massopen.cloud"
}
