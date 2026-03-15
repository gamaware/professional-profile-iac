output "website_url" {
  description = "URL of the website"
  value       = "https://${var.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.id
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.this.zone_id
}
