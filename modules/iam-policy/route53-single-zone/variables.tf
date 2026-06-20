variable "zone_name" {
  description = "Name of the Route53 hosted zone (e.g. example.com)"
  type        = string
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
