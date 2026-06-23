variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "allow_public_access" {
  description = "When false, block all public access to the bucket"
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "S3 storage class for lifecycle transition (e.g. GLACIER, GLACIER_IR, STANDARD_IA, DEEP_ARCHIVE). When null, no lifecycle rule is created."
  type        = string
  default     = null

  validation {
    condition = var.storage_class == null || contains(
      ["STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER_IR", "GLACIER", "DEEP_ARCHIVE"],
      var.storage_class
    )
    error_message = "storage_class must be one of: STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, DEEP_ARCHIVE"
  }
}
