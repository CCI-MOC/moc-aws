variable "name" {
  description = "Name of the IAM user"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the IAM user"
  type        = map(string)
  default     = {}
}

variable "policy_arns" {
  description = "Map of managed policy ARNs to attach to the user (key = stable name, value = ARN)"
  type        = map(string)
  default     = {}
}
