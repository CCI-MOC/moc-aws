# -- innabox-dns-manager ------------------------------------------------

module "route53_policy_innabox" {
  source             = "../modules/iam-policy/route53-single-zone"
  zone_name          = "box.massopen.cloud"
  policy_name        = "box-massopen-cloud"
  policy_description = "allow cert-manager in innabox dev cluster to manage box.massopen.cloud"
}

module "innbox_dns_manager" {
  source = "../modules/iam-user"
  name   = "innabox-dns-manager"
  policy_arns = {
    ocp-massopen-cloud = module.route53_policy_innabox.policy_arn
  }
  tags = {
    AKIAYLUGMT7YLZGBNPO2 = "create dns record for innabox tenant clusters"
    AKIAYLUGMT7YL5VWQTCR = "innabox AAP credentials"
  }
}
