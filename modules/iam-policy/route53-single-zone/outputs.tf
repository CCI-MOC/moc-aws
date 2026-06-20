output "policy_arn" {
  value = aws_iam_policy.this.arn
}

output "zone_arn" {
  value = data.aws_route53_zone.this.arn
}

output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}
