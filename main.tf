terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.12"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # This applies the "managed-by: moc-aws" tag to all resources created by this
  # repository. This is useful in e.g. resource explorer queries to identify
  # unmanaged resources.
  #
  # aws resource-explorer-2 search --query-string='-tag:managed-by=moc-aws'
  default_tags {
    tags = {
      managed-by = "moc-aws"
    }
  }
}

module "github-oidc" {
  source         = "./modules/github-oidc"
  dns_policy_arn = aws_iam_policy.route53_records.arn
}

module "wasabi" {
  source = "./wasabi"

  wasabi_access_key = var.wasabi_access_key
  wasabi_secret_key = var.wasabi_secret_key

  providers = {
    aws = aws
  }
}

module "b2" {
  source = "./b2"

  b2_access_key = var.b2_access_key
  b2_secret_key = var.b2_secret_key

  providers = {
    aws = aws
  }
}
