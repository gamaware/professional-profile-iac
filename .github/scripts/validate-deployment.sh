#!/usr/bin/env bash
set -euo pipefail

echo "=== Post-Deployment Validation ==="
echo ""
ERRORS=0

# Validate S3 bucket exists
if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
  echo "PASS: S3 bucket '$S3_BUCKET' exists"
else
  echo "FAIL: S3 bucket '$S3_BUCKET' not found"
  ERRORS=$((ERRORS + 1))
fi

# Validate CloudFront distribution
if [ "$CLOUDFRONT_ID" != "" ]; then
  STATUS=$(aws cloudfront get-distribution --id "$CLOUDFRONT_ID" \
    --query 'Distribution.Status' --output text 2>/dev/null || echo "UNKNOWN")
  if [ "$STATUS" = "Deployed" ]; then
    echo "PASS: CloudFront distribution '$CLOUDFRONT_ID' status: $STATUS"
  else
    echo "WARN: CloudFront distribution '$CLOUDFRONT_ID' status: $STATUS"
  fi
else
  echo "FAIL: CloudFront distribution ID not available"
  ERRORS=$((ERRORS + 1))
fi

# Validate website responds
if curl -sf "https://$EXPECTED_DOMAIN" > /dev/null 2>&1; then
  echo "PASS: Website at https://$EXPECTED_DOMAIN is responding"
else
  echo "WARN: Website at https://$EXPECTED_DOMAIN not responding (may need cache invalidation)"
fi

# Validate HTTPS redirect
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "http://$EXPECTED_DOMAIN" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
  echo "PASS: HTTP redirects to HTTPS (HTTP $HTTP_CODE)"
else
  echo "WARN: HTTP redirect check returned HTTP $HTTP_CODE"
fi

echo ""
echo "=== Validation Complete ($ERRORS errors) ==="

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
