terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
  }
}

locals {
  default_tags = {
    ManagedBy  = "terraform"
    Repository = "professional-profile-iac"
    Project    = "professional-profile"
    Owner      = "gamaware"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}

# CloudFront requires ACM certificates in us-east-1
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile

  default_tags {
    tags = local.default_tags
  }
}
