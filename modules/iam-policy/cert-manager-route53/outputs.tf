output "policy_arn" {
  value = aws_iam_policy.this.arn
}

output "policy_name" {
  value = aws_iam_policy.this.name
}

output "zone_arn" {
  value = data.aws_route53_zone.this.arn
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}
