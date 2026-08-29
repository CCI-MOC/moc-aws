# -----------------------------------------------------------------------------
# Route53 zone policies for cert-manager
# -----------------------------------------------------------------------------

locals {
  cert_manager_policies = {
    "cert_manager_policy_oac_prod_infra" = {
      zone_name          = "ocp.massopen.cloud"
      cluster_subdomain  = "infra.oac.ocp.massopen.cloud"
      policy_name        = "cert-manager-oac-prod-infra"
      policy_description = "modify records in infra.oac.ocp.massopen.cloud for dns01 challenges."
      additional_challenge_names = [
        "*.hcp.oac.massopen.cloud",
        "*.hcp-int.oac.massopen.cloud"
      ]
    }
    "cert_manager_policy_storage_massopen" = {
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-storage-massopen-cloud"
      policy_description = "allow issuing certificate for storage.massopen.cloud object storage proxy"
      additional_challenge_names = [
        "storage.massopen.cloud"
      ]
    }
    "cert_manager_policy_infra_ocp_massopen" = {
      cluster_subdomain  = "infra.ocp.massopen.cloud"
      zone_name          = "ocp.massopen.cloud"
      policy_name        = "cert-manager-infra-ocp-massopen-cloud"
      policy_description = "modify records in infra.ocp.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_staging_ocp_massopen" = {
      cluster_subdomain  = "staging.ocp.massopen.cloud"
      zone_name          = "ocp.massopen.cloud"
      policy_name        = "cert-manager-staging-ocp-massopen-cloud"
      policy_description = "modify records in staging.ocp.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_moc_infra_massopen" = {
      cluster_subdomain  = "moc-infra.massopen.cloud"
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-moc-infra-massopen-cloud"
      policy_description = "modify records in moc-infra.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_esi_massopen" = {
      cluster_subdomain  = "esi.massopen.cloud"
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-esi-massopen-cloud"
      policy_description = "modify records for esi.massopen.cloud for dns01 challenges."
    }
    "cert_manager_policy_oac_infra" = {
      cluster_subdomain  = "infra.oac.int.massopen.cloud"
      zone_name          = "int.massopen.cloud"
      policy_name        = "cert-manager-oac-infra-int-massopen-cloud"
      policy_description = "modify records in infra.oac.int.massopen.cloud for dns01 challenges."
      additional_challenge_names = [
        "*.apps.infra.oac.int.massopen.cloud"
      ]
    }
    "cert_manager_policy_oac_dev_workload0" = {
      cluster_subdomain  = "apps.oac-prod.apps.infra.oac.int.massopen.cloud"
      zone_name          = "int.massopen.cloud"
      policy_name        = "cert-manager-oac-dev-workload0-int-massopen-cloud"
      policy_description = "modify records for oac-prod hosted cluster dns01 challenges."
    }
    "cert_manager_policy_sso_massopen" = {
      cluster_subdomain  = "sso.massopen.cloud"
      zone_name          = "massopen.cloud"
      policy_name        = "cert-manager-sso-massopen-cloud"
      policy_description = "modify records for sso.massopen.cloud for dns01 challenges."
    }
  }
}

module "cert_manager_policy" {
  for_each                   = local.cert_manager_policies
  source                     = "./modules/iam-policy/cert-manager-route53"
  cluster_subdomain          = try(each.value.cluster_subdomain, null)
  zone_name                  = each.value.zone_name
  policy_name                = each.value.policy_name
  policy_description         = each.value.policy_description
  additional_challenge_names = try(each.value.additional_challenge_names, [])
}
