terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      ManagedBy  = "terraform"
      Repository = "professional-profile-iac"
      Project    = "professional-profile"
      Owner      = "gamaware"
    }
  }
}

# CloudFront requires ACM certificates in us-east-1
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile

  default_tags {
    tags = {
      ManagedBy  = "terraform"
      Repository = "professional-profile-iac"
      Project    = "professional-profile"
      Owner      = "gamaware"
    }
  }
}
