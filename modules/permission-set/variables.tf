variable "instance_arn" {
  description = "ARN of the SSO instance"
  type        = string
}

variable "name" {
  description = "Name of the permission set"
  type        = string
}

variable "description" {
  description = "Description of the permission set"
  type        = string
  default     = null
}

variable "session_duration" {
  description = "Session duration in ISO 8601 format"
  type        = string
  default     = "PT2H"
}

variable "managed_policy_arns" {
  description = "Map of AWS managed policy ARNs to attach (key = stable name, value = ARN)"
  type        = map(string)
  default     = {}
}

variable "customer_managed_policy_names" {
  description = "Map of customer managed policy names to attach (key = stable name, value = policy name)"
  type        = map(string)
  default     = {}
}

variable "assignments" {
  description = "Map of account assignments (key = stable name, value = assignment config)"
  type = map(object({
    principal_id   = string
    principal_type = string
    target_id      = string
  }))
  default = {}
}
