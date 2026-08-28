variable "zone_name" {
  description = "Name of the Route53 hosted zone to look up (used only when zone_arn is not set)"
  type        = string
  default     = null
}

variable "zone_arn" {
  description = "ARN of a hosted zone managed elsewhere in this config. When set, skips the data-source lookup and depends on the resource directly."
  type        = string
  default     = null
}

variable "policy_name" {
  description = "Name for the IAM policy"
  type        = string
}

variable "policy_description" {
  description = "Description for the IAM policy"
  type        = string
  default     = ""
}
