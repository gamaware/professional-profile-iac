# Run: printf 'terraform {\n  backend "local" {}\n}\n' > backend_override.tf && terraform init -reconfigure && terraform test -verbose && rm backend_override.tf

mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      id                          = "alexgarcia.info"
      arn                         = "arn:aws:s3:::alexgarcia.info"
      bucket                      = "alexgarcia.info"
      bucket_regional_domain_name = "alexgarcia.info.s3.us-east-1.amazonaws.com"
    }
  }
  mock_resource "aws_cloudfront_distribution" {
    defaults = {
      id             = "E1234567890" # pragma: allowlist secret
      arn            = "arn:aws:cloudfront::123456789012:distribution/E1234567890"
      domain_name    = "d1234567890.cloudfront.net"
      hosted_zone_id = "Z2FDTNDATAQYW2"
    }
  }
  mock_resource "aws_cloudfront_origin_access_control" {
    defaults = {
      id = "E1234567890OAC"
    }
  }
  mock_resource "aws_route53_record" {
    defaults = {}
  }
  mock_resource "aws_s3_bucket_policy" {
    defaults = {}
  }
  mock_resource "aws_s3_bucket_public_access_block" {
    defaults = {}
  }
  mock_resource "aws_s3_bucket_website_configuration" {
    defaults = {}
  }
  mock_data "aws_route53_zone" {
    defaults = {
      zone_id = "Z1234567890"
      name    = "alexgarcia.info"
    }
  }
}

mock_provider "aws" {
  alias = "us_east_1"
  mock_data "aws_acm_certificate" {
    defaults = {
      arn    = "arn:aws:acm:us-east-1:123456789012:certificate/mock-cert-id"
      domain = "alexgarcia.info"
    }
  }
}

run "valid_defaults" {
  command = plan

  assert {
    condition     = var.aws_region == "us-east-1"
    error_message = "Default region should be us-east-1"
  }

  assert {
    condition     = var.aws_profile == null
    error_message = "Default profile should be null"
  }

  assert {
    condition     = var.domain_name == "alexgarcia.info"
    error_message = "Default domain should be alexgarcia.info"
  }
}

run "null_profile" {
  command = plan

  variables {
    aws_profile = null
  }

  assert {
    condition     = var.aws_profile == null
    error_message = "Profile should accept null"
  }
}

run "custom_domain" {
  command = plan

  variables {
    domain_name = "example.com"
  }

  assert {
    condition     = var.domain_name == "example.com"
    error_message = "Domain should accept custom values"
  }
}
