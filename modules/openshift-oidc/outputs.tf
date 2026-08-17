output "cert_manager_role_arn" {
  description = "ARN of the IAM role for cert-manager"
  value       = aws_iam_role.cert_manager.arn
}

output "eso_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  value       = aws_iam_role.eso.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL (the S3 path used as the cluster's serviceAccountIssuer)"
  value       = local.oidc_issuer_url
}
