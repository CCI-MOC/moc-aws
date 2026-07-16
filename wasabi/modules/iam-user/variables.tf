variable "name" {
  description = "Name of the IAM user"
  type        = string
}

variable "allow_change_password" {
  description = "Whether to attach the IAMUserChangePassword policy to the user"
  type        = bool
  default     = false
}

variable "policies" {
  description = "List of additional policy ARNs to attach to the user"
  type        = list(string)
  default     = []
}

variable "secret_recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion)"
  type        = number
  default     = 30
}
