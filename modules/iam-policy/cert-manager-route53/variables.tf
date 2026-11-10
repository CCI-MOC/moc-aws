variable "zone_arn" {
  type        = string
  description = "ARN of the primary Route 53 Hosted Zone"
}

variable "policy_name" {
  type        = string
  description = "Name of the IAM Policy"
}

variable "policy_description" {
  type        = string
  default     = "Scoped Route53 policy for cert-manager DNS-01 challenges"
  description = "Description of the IAM Policy"
}

variable "cluster_subdomain" {
  type        = string
  default     = null
  description = "The specific cluster subdomain prefix allowed for DNS-01 challenges (e.g., cluster1.ocp.example.com). Generates api/apps/_acme-challenge patterns automatically."
}

variable "additional_challenge_names" {
  type        = list(string)
  default     = []
  description = "Additional DNS names for which _acme-challenge TXT records are permitted (e.g., api-cluster.apps.example.com). Each entry is prefixed with _acme-challenge automatically."
}

variable "additional_zone_names" {
  type        = list(string)
  default     = []
  description = "Additional Route 53 Hosted Zone names whose records this policy may modify. Use when challenge names live in delegated subdomains that have their own hosted zones (e.g., hcp.oac.massopen.cloud)."
}

variable "additional_zone_arns" {
  type        = map(string)
  default     = {}
  description = "ARNs of the hosted zones named in additional_zone_names, keyed by zone name. Must have an entry for every name in additional_zone_names."
}
