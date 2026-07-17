output "application_key_id" {
  description = "The application key ID"
  value       = b2_application_key.this.application_key_id
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret containing the key"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret containing the key"
  value       = aws_secretsmanager_secret.this.name
}
