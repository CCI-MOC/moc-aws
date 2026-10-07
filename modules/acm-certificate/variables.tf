variable "domain_name" {
  description = "Fully-qualified domain name for the ACM certificate"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID in which to create the DNS validation records"
  type        = string
}
