#!/usr/bin/env bash
set -euo pipefail

echo "website_url=$(terraform output -raw website_url 2>/dev/null || echo '')" >> "$GITHUB_OUTPUT"
echo "cloudfront_id=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || echo '')" >> "$GITHUB_OUTPUT"
echo "s3_bucket=$(terraform output -raw s3_bucket_name 2>/dev/null || echo '')" >> "$GITHUB_OUTPUT"
