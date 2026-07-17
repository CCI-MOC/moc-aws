terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

resource "b2_bucket" "this" {
  bucket_name = var.name
  bucket_type = var.bucket_type

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}
