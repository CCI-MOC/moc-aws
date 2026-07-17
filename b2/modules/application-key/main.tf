terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "b2_application_key" "this" {
  key_name     = var.key_name
  capabilities = var.capabilities
  bucket_ids   = var.bucket_ids
  name_prefix  = var.name_prefix
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "b2-key/${var.key_name}"
  description             = var.description
  recovery_window_in_days = var.secret_recovery_window_in_days
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    application_key_id = b2_application_key.this.application_key_id
    application_key    = b2_application_key.this.application_key
  })
}
