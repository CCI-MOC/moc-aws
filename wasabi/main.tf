terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias      = "wasabi"
  region     = "us-east-1"
  access_key = var.wasabi_access_key
  secret_key = var.wasabi_secret_key

  endpoints {
    iam = "https://iam.wasabisys.com"
    s3  = "https://s3.wasabisys.com"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # Disabled due to lack of tagging support in the wasabi api
  # default_tags {
  #   tags = {
  #     managed-by = "moc-aws"
  #   }
  # }
}
