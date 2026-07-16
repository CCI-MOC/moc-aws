# -----------------------------------------------------------------------------
# Route53 zone policies
# -----------------------------------------------------------------------------

module "cert_manager_policy_ocp_massopen" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "ocp.massopen.cloud"
  policy_name        = "cert-manager-ocp-massopen-cloud"
  policy_description = "modify records in ocp.massopen.cloud mainly for the purposes for dns01 challenged."
}

module "cert_manager_policy_innabox" {
  source             = "./modules/iam-policy/route53-single-zone"
  zone_name          = "box.massopen.cloud"
  policy_name        = "cert-manager-box-massopen-cloud"
  policy_description = "allow cert-manager in innabox dev cluster to manage box.massopen.cloud"
}

# -----------------------------------------------------------------------------
# IAM users
# -----------------------------------------------------------------------------

locals {
  iam_users = {
    "cert-manager-ocp-massopen" = {
      access_keys = {
        cert-manager-nist-clusters = "Used by cert-manager in NIST clusters for dns01 challenges"
      }
      policy_arns = {
        cert-manager-ocp-massopen-cloud = module.cert_manager_policy_ocp_massopen.policy_arn
      }
    }
    "innabox-dns-manager" = {
      access_keys = {
        innabox-dns = "Used by cert-manager in innabox dev cluster"
        innabox-aap = "Used by AAP in innabox dev cluster"
      }
      policy_arns = {
        cert-manager-box-massopen-cloud = module.cert_manager_policy_innabox.policy_arn
      }
    }
  }
}

module "iam_user" {
  for_each                       = local.iam_users
  source                         = "./modules/iam-user"
  name                           = each.key
  tags                           = try(each.value.tags, {})
  access_keys                    = try(each.value.access_keys, {})
  policy_arns                    = try(each.value.policy_arns, {})
  secret_recovery_window_in_days = try(each.value.secret_recovery_window_in_days, 30)
}
