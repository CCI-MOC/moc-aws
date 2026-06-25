variable "name" {
  description = "Name of the IAM user"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the IAM user"
  type        = map(string)
  default     = {}
}

variable "access_keys" {
  description = "Map of access key labels to descriptions"
  type        = map(string)
  default     = {}
}

variable "policy_arns" {
  description = "Map of managed policy ARNs to attach to the user (key = stable name, value = ARN)"
  type        = map(string)
  default     = {}
}

variable "secret_recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion)"
  type        = number
  default     = 30
}

variable "path" {
  description = "Used to organize users in a hierarchical structure"
  type        = string
  default     = "/"
}
