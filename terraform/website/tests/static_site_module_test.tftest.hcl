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

run "static_site_configuration" {
  command = apply

  # S3 bucket
  assert {
    condition     = module.static_site.s3_bucket_name == "alexgarcia.info"
    error_message = "S3 bucket name should match the domain name"
  }

  # S3 public access block
  assert {
    condition     = module.static_site.s3_bucket_name != ""
    error_message = "S3 bucket name should not be empty"
  }

  # CloudFront outputs
  assert {
    condition     = module.static_site.cloudfront_distribution_id != ""
    error_message = "CloudFront distribution ID should not be empty"
  }

  assert {
    condition     = module.static_site.cloudfront_domain_name != ""
    error_message = "CloudFront domain name should not be empty"
  }

  # Website URL
  assert {
    condition     = output.website_url == "https://alexgarcia.info"
    error_message = "Website URL should be https://alexgarcia.info"
  }

  # All outputs non-empty
  assert {
    condition     = output.cloudfront_distribution_id != ""
    error_message = "CloudFront distribution ID output should not be empty"
  }

  assert {
    condition     = output.s3_bucket_name != ""
    error_message = "S3 bucket name output should not be empty"
  }
}
