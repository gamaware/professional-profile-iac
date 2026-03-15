terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# ─── S3 Bucket ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "this" {
  bucket = var.domain_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# ─── CloudFront Origin Access Control ────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.domain_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─── ACM Certificate (data source — managed outside this module) ─────────────

data "aws_acm_certificate" "this" {
  provider = aws.us_east_1
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

# ─── CloudFront Distribution ─────────────────────────────────────────────────

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = "S3-${var.domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  default_root_object = var.index_document
  aliases             = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/${var.error_document}"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/${var.error_document}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.this.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# ─── S3 Bucket Policy (CloudFront OAC access only) ──────────────────────────

resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket_public_access_block.this]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

# ─── Route 53 DNS Record ─────────────────────────────────────────────────────

data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
