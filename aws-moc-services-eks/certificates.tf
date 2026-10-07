# -----------------------------------------------------------------------------
# Route53 zones
# -----------------------------------------------------------------------------

data "aws_route53_zone" "int_massopen_cloud" {
  name         = "int.massopen.cloud"
  private_zone = false
}

data "aws_route53_zone" "massopen_cloud" {
  name         = "massopen.cloud"
  private_zone = false
}

# -----------------------------------------------------------------------------
# ACM certificates
# -----------------------------------------------------------------------------

module "cert_argocd" {
  source = "../modules/acm-certificate"

  domain_name = "argocd.moc-services.int.massopen.cloud"
  zone_id     = data.aws_route53_zone.int_massopen_cloud.zone_id
}

module "cert_sso" {
  source = "../modules/acm-certificate"

  domain_name = "sso.massopen.cloud"
  zone_id     = data.aws_route53_zone.massopen_cloud.zone_id
}
