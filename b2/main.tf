terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.12"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "b2" {
  application_key_id = var.b2_access_key
  application_key    = var.b2_secret_key
}
