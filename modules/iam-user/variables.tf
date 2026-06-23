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
  description = "Set of access key labels to create for this user"
  type        = set(string)
  default     = []
}

variable "policy_arns" {
  description = "Map of managed policy ARNs to attach to the user (key = stable name, value = ARN)"
  type        = map(string)
  default     = {}
}
