variable "key_name" {
  description = "Name for the application key"
  type        = string
}

variable "capabilities" {
  description = "List of capabilities granted to the key"
  type        = set(string)
}

variable "bucket_ids" {
  description = "Restrict the key to specific buckets"
  type        = set(string)
  default     = null
}

variable "name_prefix" {
  description = "Restrict access to files with this prefix"
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the Secrets Manager secret"
  type        = string
  default     = ""
}

variable "secret_recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion)"
  type        = number
  default     = 30
}
