variable "name" {
  description = "Name of the B2 bucket"
  type        = string
}

variable "bucket_type" {
  description = "Bucket type (allPrivate or allPublic)"
  type        = string
  default     = "allPrivate"
}
