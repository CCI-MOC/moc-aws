# -- cert-manager-ocp-massopen ------------------------------------------------

module "route53_policy_ocp_massopen" {
  source             = "../modules/iam-policy/route53-single-zone"
  zone_name          = "ocp.massopen.cloud"
  policy_name        = "ocp-massopen-cloud"
  policy_description = "modify records in ocp.massopen.cloud mainly for the purposes for dns01 challenged."
}

module "cert_manager_ocp_massopen" {
  source = "../modules/iam-user"
  name   = "cert-manager-ocp-massopen"
  policy_arns = {
    ocp-massopen-cloud = module.route53_policy_ocp_massopen.policy_arn
  }
  tags = {
    "AKIAYLUGMT7YKZRT4APO" = "cert-manager-nist-clusters"
  }
}
