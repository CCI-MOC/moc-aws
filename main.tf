terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.12"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # This applies the "managed-by: moc-aws" tag to all resources created by this
  # repository. This is useful in e.g. resource explorer queries to identify
  # unmanaged resources.
  #
  # aws resource-explorer-2 search --query-string='-tag:managed-by=moc-aws'
  default_tags {
    tags = {
      managed-by = "moc-aws"
    }
  }
}

module "github-oidc" {
  source         = "./modules/github-oidc"
  dns_policy_arn = aws_iam_policy.route53_records.arn

  consumer_repos = {
    moc-keycloak = {
      repository         = "CCI-MOC/moc-keycloak"
      state_keys         = ["moc-keycloak"]
      ro_secret_prefixes = ["cluster/moc-services/"]
      rw_secret_prefixes = ["cluster/*/keycloak-oidc"]
      # moc-keycloak's OIDC subject uses GitHub's immutable org/repo IDs, so the
      # default "repo:CCI-MOC/moc-keycloak:*" cannot match. Value obtained with:
      #   gh api repos/CCI-MOC/moc-keycloak/actions/oidc/customization/sub --jq .sub_claim_prefix
      subject_claims = ["repo:CCI-MOC@3578683/moc-keycloak@1352835750:*"]
    }
  }
}

locals {
  # Defaults for every openshift_oidc_clusters entry. Each cluster below is
  # built with merge(local.openshift_oidc_cluster_defaults, { ... }) so that
  # every entry ends up with an identical set of keys. This keeps the map
  # homogeneous, which OpenTofu requires: if entries had differing key sets it
  # would unify them into a single object type and backfill the missing keys as
  # "known after apply", causing a cryptic for_each error downstream.
  #
  # Required keys default to null; the module marks them nullable = false so an
  # omitted required key fails with a clear message naming the cluster. Optional
  # keys default to a usable empty value.
  openshift_oidc_cluster_defaults = {
    cluster_name                 = null # required
    oidc_bucket_domain_name      = null # required
    cert_manager_policy_arn      = null # required
    eso_writable_secret_prefixes = []   # optional
    service_account_roles        = {}   # optional
  }

  openshift_oidc_clusters = {
    oac_infra = merge(local.openshift_oidc_cluster_defaults, {
      cluster_name            = "oac-infra-dev"
      oidc_bucket_domain_name = aws_s3_bucket.oac_oidc.bucket_regional_domain_name
      cert_manager_policy_arn = module.cert_manager_policy["cert_manager_policy_oac_infra"].policy_arn
      eso_writable_secret_prefixes = [
        "cluster/oac-infra-dev/hostedcluster/",
        "cluster/common/object-storage-proxy/certificate",
      ]
      service_account_roles = {
        object-storage-certificate = {
          namespace       = "object-storage-certificate"
          service_account = "object-storage-certificate"
          policy_arns     = [module.cert_manager_policy["cert_manager_policy_storage_massopen"].policy_arn]
        }
      }
    })
    oac_dev_workload0 = merge(local.openshift_oidc_cluster_defaults, {
      cluster_name            = "oac-dev-workload0"
      oidc_bucket_domain_name = aws_s3_bucket.oac_oidc.bucket_regional_domain_name
      cert_manager_policy_arn = module.cert_manager_policy["cert_manager_policy_oac_dev_workload0"].policy_arn
    })
    oac_prod_infra = merge(local.openshift_oidc_cluster_defaults, {
      cluster_name            = "oac-prod-infra"
      oidc_bucket_domain_name = aws_s3_bucket.oac_oidc.bucket_regional_domain_name
      cert_manager_policy_arn = module.cert_manager_policy["cert_manager_policy_oac_prod_infra"].policy_arn
      eso_writable_secret_prefixes = [
        "cluster/oac-prod-infra/hostedcluster/",
      ]
    })
    oac_prod_workload0 = merge(local.openshift_oidc_cluster_defaults, {
      cluster_name            = "oac-prod-workload0"
      oidc_bucket_domain_name = aws_s3_bucket.oac_oidc.bucket_regional_domain_name
      cert_manager_policy_arn = module.cert_manager_policy["cert_manager_policy_oac_prod_workload0"].policy_arn
    })
  }
}

module "openshift_oidc" {
  for_each = local.openshift_oidc_clusters

  source                       = "./modules/openshift-oidc"
  cluster_name                 = each.value.cluster_name
  oidc_bucket_domain_name      = each.value.oidc_bucket_domain_name
  cert_manager_policy_arn      = each.value.cert_manager_policy_arn
  eso_writable_secret_prefixes = each.value.eso_writable_secret_prefixes
  service_account_roles        = each.value.service_account_roles
}

module "wasabi" {
  source = "./wasabi"

  wasabi_access_key = var.wasabi_access_key
  wasabi_secret_key = var.wasabi_secret_key

  providers = {
    aws = aws
  }
}

module "b2" {
  source = "./b2"

  b2_access_key = var.b2_access_key
  b2_secret_key = var.b2_secret_key

  providers = {
    aws = aws
  }
}
