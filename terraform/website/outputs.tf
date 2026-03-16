output "website_url" {
  description = "URL of the website"
  value       = module.static_site.website_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = module.static_site.cloudfront_distribution_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for deployments"
  value       = module.static_site.s3_bucket_name
}
