variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "policies" {
  description = "List of JSON policy documents to attach to the bucket"
  type        = list(string)
  default     = []
}

variable "managed_by" {
  description = "Value for the managed-by tag"
  type        = string
  default     = "moc-aws"
}
