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
# Route53 zone policies for cert-manager
# -----------------------------------------------------------------------------

locals {
  cert_manager_policies = {
    "cert_manager_policy_infra_ocp_massopen" = {
      cluster_subdomain   = "infra.ocp.massopen.cloud"
      zone_name          = "ocp.massopen.cloud"
      policy_name        = "cert-manager-infra-ocp-massopen-cloud"
      policy_description = "modify records in infra.ocp.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_staging_ocp_massopen" = {
      cluster_subdomain   = "staging.ocp.massopen.cloud"
      zone_name          = "ocp.massopen.cloud"
      policy_name        = "cert-manager-staging-ocp-massopen-cloud"
      policy_description = "modify records in staging.ocp.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_moc_infra_massopen" = {
      cluster_subdomain   = "moc-infra.massopen.cloud"
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-moc-infra-massopen-cloud"
      policy_description = "modify records in moc-infra.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_esi_massopen" = {
      cluster_subdomain   = "esi.massopen.cloud"
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-esi-massopen-cloud"
      policy_description = "modify records for esi.massopen.cloud for dns01 challenges."
    }
  }
}

module "cert_manager_policy" {
  for_each        = local.cert_manager_policies
  source             = "./modules/iam-policy/cert-manager-route53"
  cluster_subdomain   = each.value.cluster_subdomain
  zone_name          = each.value.zone_name
  policy_name        = each.value.policy_name
  policy_description = each.value.policy_description
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
    "cert-manager-infra-ocp-massopen" = {
      access_keys = {
        cert-manager-infra-ocp-massopen = "Used by certmanager in infra.ocp.massopen.cloud for dns01 challenges"
      }
      policy_arns = {
        cert-manager-infra-ocp-massopen-cloud = module.cert_manager_policy["cert_manager_policy_infra_ocp_massopen"].policy_arn
      }
    }
    "cert-manager-staging-ocp-massopen" = { # import it
      access_keys = {
        cert-manager-staging-ocp-massopen = "Used by certmanager in staging.ocp.massopen.cloud for dns01 challenges"
      }
      policy_arns = {
        cert-manager-staging-ocp-massopen-cloud = module.cert_manager_policy["cert_manager_policy_staging_ocp_massopen"].policy_arn
      }
    }
    "cert-manager-moc-infra" = { # import it
      access_keys = {
        cert-manager-moc-infra-massopen = "Used by certmanager in moc-infra.massopen.cloud for dns01 challenges"
      }
      policy_arns = {
        cert-manager-moc-infra-massopen-cloud = module.cert_manager_policy["cert_manager_policy_moc_infra_massopen"].policy_arn
      }
    }
    "certbot-letsencrypt-esi" = { # import it
      access_keys = {
        certbot-letsencrypt-esi = "Used by certbot in ESI cluster for dns01 challenges"
      }
      policy_arns = {
        cert-manager-esi-massopen-cloud = module.cert_manager_policy["cert_manager_policy_esi_massopen"].policy_arn
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
