# -----------------------------------------------------------------------------
# IAM users
# -----------------------------------------------------------------------------

locals {
  policy_arn_map = {
    cert-manager-box-massopen-cloud         = module.cert_manager_policy_innabox.policy_arn
    cert-manager-infra-ocp-massopen-cloud   = module.cert_manager_policy["cert_manager_policy_infra_ocp_massopen"].policy_arn
    cert-manager-staging-ocp-massopen-cloud = module.cert_manager_policy["cert_manager_policy_staging_ocp_massopen"].policy_arn
    cert-manager-moc-infra-massopen-cloud   = module.cert_manager_policy["cert_manager_policy_moc_infra_massopen"].policy_arn
    cert-manager-esi-massopen-cloud         = module.cert_manager_policy["cert_manager_policy_esi_massopen"].policy_arn
    external-dns-int-massopen-cloud         = module.external_dns_policy_int_massopen.policy_arn
    cert-manager-sso-massopen-cloud         = module.cert_manager_policy["cert_manager_policy_sso_massopen"].policy_arn
  }

  iam_users = {
    "oac-dev-external-dns" = {
      access_keys = {
        oac-dev-infra-external-dns = "Used by external dns operator on the oac-dev-infra cluster"
      }
      policy_names = ["external-dns-int-massopen-cloud"]
    }
    "innabox-dns-manager" = {
      access_keys = {
        innabox-dns = "Used by cert-manager in innabox dev cluster"
        innabox-aap = "Used by AAP in innabox dev cluster"
      }
      policy_names = ["cert-manager-box-massopen-cloud"]
    }
    "cert-manager-infra-ocp-massopen" = {
      access_keys = {
        cert-manager-infra-ocp-massopen = "Used by certmanager in infra.ocp.massopen.cloud for dns01 challenges"
      }
      policy_names = ["cert-manager-infra-ocp-massopen-cloud"]
    }
    "cert-manager-staging-ocp-massopen" = {
      access_keys = {
        cert-manager-staging-ocp-massopen = "Used by certmanager in staging.ocp.massopen.cloud for dns01 challenges"
      }
      policy_names = ["cert-manager-staging-ocp-massopen-cloud"]
    }
    "cert-manager-moc-infra" = {
      access_keys = {
        cert-manager-moc-infra-massopen = "Used by certmanager in moc-infra.massopen.cloud for dns01 challenges"
      }
      policy_names = ["cert-manager-moc-infra-massopen-cloud"]
    }
    "certbot-letsencrypt-esi" = {
      access_keys = {
        certbot-letsencrypt-esi = "Used by certbot in ESI cluster for dns01 challenges"
      }
      policy_names = ["cert-manager-esi-massopen-cloud"]
    }
    "certbot-letsencrypt-sso" = {
      access_keys = {
        certbot-letsencrypt-sso = "Used for sso.massopen.cloud for dns01 challenges"
      }
      policy_names = ["cert-manager-sso-massopen-cloud"]
    }
  }
}

module "iam_user" {
  for_each    = local.iam_users
  source      = "./modules/iam-user"
  name        = each.key
  tags        = try(each.value.tags, {})
  access_keys = try(each.value.access_keys, {})
  policy_arns = {
    for name in try(each.value.policy_names, []) :
    name => local.policy_arn_map[name]
  }
  secret_recovery_window_in_days = try(each.value.secret_recovery_window_in_days, 30)
}
