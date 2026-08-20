variable "cluster_name" {
  type        = string
  description = "Short identifier for the cluster, used in resource names and S3 path prefix (e.g., oac-infra, oac-staging)"
}

variable "oidc_bucket_domain_name" {
  type        = string
  description = "Regional domain name of the shared S3 bucket hosting OIDC discovery documents"
}

variable "cert_manager_policy_arn" {
  type        = string
  description = "ARN of the IAM policy granting Route53 access for cert-manager DNS-01 challenges"
}

variable "eso_writable_secret_prefixes" {
  type        = list(string)
  description = "List of Secrets Manager name prefixes that ESO is allowed to create (e.g. 'cluster/my-cluster/hostedcluster/')"
  default     = []
}
