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
