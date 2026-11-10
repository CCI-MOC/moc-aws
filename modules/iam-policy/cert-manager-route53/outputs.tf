output "policy_arn" {
  value = aws_iam_policy.this.arn
}

output "policy_name" {
  value = aws_iam_policy.this.name
}

output "zone_arn" {
  value = var.zone_arn
}
