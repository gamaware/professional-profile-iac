#!/usr/bin/env bash
set -euo pipefail

echo "=== Post-Destroy Validation ==="
echo ""

# Verify S3 bucket no longer exists
if aws s3api head-bucket --bucket "$EXPECTED_DOMAIN" 2>/dev/null; then
  echo "WARN: S3 bucket '$EXPECTED_DOMAIN' still exists"
else
  echo "PASS: S3 bucket '$EXPECTED_DOMAIN' has been removed"
fi

# Verify CloudFront distribution no longer exists
DIST_COUNT=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Aliases.Items[0]=='$EXPECTED_DOMAIN'] | length(@)" \
  --output text 2>/dev/null || echo "0")
if [ "$DIST_COUNT" = "0" ]; then
  echo "PASS: No CloudFront distribution found for $EXPECTED_DOMAIN"
else
  echo "WARN: CloudFront distribution for $EXPECTED_DOMAIN still exists"
fi

echo ""
echo "=== Destroy Validation Complete ==="
