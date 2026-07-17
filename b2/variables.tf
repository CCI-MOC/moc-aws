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
