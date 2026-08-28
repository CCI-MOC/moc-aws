output "policy_arn" {
  value = aws_iam_policy.this.arn
}

output "zone_arn" {
  value = local.zone_arn
}
