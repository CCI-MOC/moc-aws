variable "aws_account_id" {
  description = "Primary AWS account ID"
  type        = string
}

variable "aws_account_id_secondary" {
  description = "Secondary AWS account ID"
  type        = string
}

variable "wasabi_access_key" {
  description = "Wasabi access key"
  type        = string
  sensitive   = true
}

variable "wasabi_secret_key" {
  description = "Wasabi secret key"
  type        = string
  sensitive   = true
}

variable "b2_access_key" {
  description = "Backblaze B2 application key ID"
  type        = string
  sensitive   = true
}

variable "b2_secret_key" {
  description = "Backblaze B2 application key"
  type        = string
  sensitive   = true
}
