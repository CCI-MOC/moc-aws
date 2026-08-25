variable "cluster_name" {
  type        = string
  description = "Short identifier for the cluster, used in resource names and S3 path prefix (e.g., oac-infra, oac-staging)"
  nullable    = false
}

variable "oidc_bucket_domain_name" {
  type        = string
  description = "Regional domain name of the shared S3 bucket hosting OIDC discovery documents"
  nullable    = false
}

variable "cert_manager_policy_arn" {
  type        = string
  description = "ARN of the IAM policy granting Route53 access for cert-manager DNS-01 challenges"
  nullable    = false
}

variable "eso_writable_secret_prefixes" {
  type        = list(string)
  description = "List of Secrets Manager name prefixes that ESO is allowed to create (e.g. 'cluster/my-cluster/hostedcluster/')"
  default     = []
}

variable "service_account_roles" {
  type = map(object({
    namespace       = string
    service_account = string
    policy_arns     = list(string)
  }))
  description = "Map of arbitrary Kubernetes service accounts to IAM roles. Each entry creates a web-identity role (assumable only by system:serviceaccount:<namespace>:<service_account>) with the given policies attached. The map key is used in the role name."
  default     = {}
}
