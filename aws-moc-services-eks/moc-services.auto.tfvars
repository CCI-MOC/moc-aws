cluster_name = "moc-services"

vpc_cidr = "10.251.0.0/16"

public_subnet_cidrs = {
  "us-east-1a" = "10.251.1.0/24"
  "us-east-1b" = "10.251.2.0/24"
}

private_subnet_cidrs = {
  "us-east-1a" = "10.251.10.0/24"
  "us-east-1a" = "10.251.20.0/24"
}
