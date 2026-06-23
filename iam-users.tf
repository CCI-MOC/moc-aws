# -----------------------------------------------------------------------------
# Route53 zone policies
# -----------------------------------------------------------------------------

module "route53_policy_ocp_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "ocp.massopen.cloud"
  policy_name        = "ocp-massopen-cloud"
  policy_description = "modify records in ocp.massopen.cloud mainly for the purposes for dns01 challenged."
}

module "route53_policy_innabox" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "box.massopen.cloud"
  policy_name        = "box-massopen-cloud"
  policy_description = "allow cert-manager in innabox dev cluster to manage box.massopen.cloud"
}

# -----------------------------------------------------------------------------
# IAM users
# -----------------------------------------------------------------------------

locals {
  iam_users = {
    "cert-manager-ocp-massopen" = {
      access_keys = ["cert-manager-nist-clusters"]
      policy_arns = {
        ocp-massopen-cloud = module.route53_policy_ocp_massopen.policy_arn
      }
    }
    "innabox-dns-manager" = {
      access_keys = ["innabox-dns", "innabox-aap"]
      policy_arns = {
        box-massopen-cloud = module.route53_policy_innabox.policy_arn
      }
    }
  }
}

module "iam_user" {
  for_each    = local.iam_users
  source      = "./modules/iam-user"
  name        = each.key
  tags        = try(each.value.tags, {})
  access_keys = each.value.access_keys
  policy_arns = each.value.policy_arns
}
