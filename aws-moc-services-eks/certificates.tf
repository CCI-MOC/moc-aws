# -----------------------------------------------------------------------------
# ACM certificate for ArgoCD ingress
# -----------------------------------------------------------------------------

data "aws_route53_zone" "int_massopen_cloud" {
  name         = "int.massopen.cloud"
  private_zone = false
}

resource "aws_acm_certificate" "argocd" {
  domain_name       = "argocd.moc-services.int.massopen.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "argocd_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.argocd.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = data.aws_route53_zone.int_massopen_cloud.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "argocd" {
  certificate_arn         = aws_acm_certificate.argocd.arn
  validation_record_fqdns = [for r in aws_route53_record.argocd_cert_validation : r.fqdn]
}
