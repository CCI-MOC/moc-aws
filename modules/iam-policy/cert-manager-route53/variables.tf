variable "zone_name" {
  type        = string
  description = "The Route 53 Hosted Zone Name (e.g., ocp.example.com)"
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
  description = "The specific cluster subdomain prefix allowed for DNS-01 challenges (e.g., cluster1.ocp.example.com)"
}
