# -----------------------------------------------------------------------------
# IAM users
# -----------------------------------------------------------------------------

locals {
  policy_arn_map = {
    cert-manager-infra-ocp-massopen-cloud       = module.cert_manager_policy["cert_manager_policy_infra_ocp_massopen"].policy_arn
    cert-manager-staging-ocp-massopen-cloud     = module.cert_manager_policy["cert_manager_policy_staging_ocp_massopen"].policy_arn
    cert-manager-moc-infra-massopen-cloud       = module.cert_manager_policy["cert_manager_policy_moc_infra_massopen"].policy_arn
    cert-manager-esi-massopen-cloud             = module.cert_manager_policy["cert_manager_policy_esi_massopen"].policy_arn
    external-dns-hcp-oac-int-massopen-cloud     = module.external_dns_policy_hcp_oac_int_massopen.policy_arn
    external-dns-hcp-int-oac-int-massopen-cloud = module.external_dns_policy_hcp_int_oac_int_massopen.policy_arn
    external-dns-hcp-oac-massopen-cloud         = module.external_dns_policy_hcp_oac_massopen.policy_arn
    external-dns-hcp-int-oac-massopen-cloud     = module.external_dns_policy_hcp_int_oac_massopen.policy_arn
  }

  iam_users = {
    "oac-prod-external-dns" = {
      access_keys = {
        oac-prod-infra-external-dns = "Used by external dns operator on the oac-prod-infra cluster"
      }
      policy_names = ["external-dns-hcp-oac-massopen-cloud", "external-dns-hcp-int-oac-massopen-cloud"]
    }
    "oac-dev-external-dns" = {
      access_keys = {
        oac-dev-infra-external-dns = "Used by external dns operator on the oac-dev-infra cluster"
      }
      policy_names = ["external-dns-hcp-oac-int-massopen-cloud", "external-dns-hcp-int-oac-massopen-cloud"]
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
