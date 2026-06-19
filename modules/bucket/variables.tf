variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "allow_public_access" {
  description = "When false, block all public access to the bucket"
  type        = bool
  default     = false
}
