#!/usr/bin/env bash
set -euo pipefail

# Post-deployment validation via AWS CLI
# Required env vars: S3_BUCKET, CLOUDFRONT_ID, EXPECTED_DOMAIN

fail() { echo "FAIL: $1"; ERRORS=$((ERRORS + 1)); }
pass() { echo "PASS: $1"; }

echo "=== Post-Deployment Validation ==="
echo ""
ERRORS=0

# --- S3 Bucket ---
if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
  pass "S3 bucket '$S3_BUCKET' exists"
else
  fail "S3 bucket '$S3_BUCKET' not found"
fi

# S3 public access block
PAB=$(aws s3api get-public-access-block --bucket "$S3_BUCKET" \
  --query 'PublicAccessBlockConfiguration' --output json 2>/dev/null || echo "{}")
if echo "$PAB" | grep -q '"BlockPublicAcls": true'; then
  pass "S3 public access blocked"
else
  fail "S3 public access block not configured"
fi

# S3 website configuration
INDEX_DOC=$(aws s3api get-bucket-website --bucket "$S3_BUCKET" \
  --query 'IndexDocument.Suffix' --output text 2>/dev/null || echo "")
if [ "$INDEX_DOC" != "" ]; then
  pass "S3 website config: index document is '$INDEX_DOC'"
else
  fail "S3 website configuration not found"
fi

# S3 bucket policy — should reference CloudFront, not Principal: *
POLICY=$(aws s3api get-bucket-policy --bucket "$S3_BUCKET" \
  --query 'Policy' --output text 2>/dev/null || echo "")
if echo "$POLICY" | grep -q "cloudfront.amazonaws.com"; then
  pass "S3 bucket policy uses CloudFront service principal"
else
  fail "S3 bucket policy does not reference CloudFront (may be public)"
fi
if echo "$POLICY" | grep -q '"Principal":"\\*"' || echo "$POLICY" | grep -q '"Principal": "\\*"'; then
  fail "S3 bucket policy has Principal: * (public access)"
else
  pass "S3 bucket policy does not grant public access"
fi

# --- CloudFront Distribution ---
if [ "$CLOUDFRONT_ID" = "" ]; then
  fail "CloudFront distribution ID not available"
else
  CF_STATUS=$(aws cloudfront get-distribution --id "$CLOUDFRONT_ID" \
    --query 'Distribution.Status' --output text 2>/dev/null || echo "UNKNOWN")
  if [ "$CF_STATUS" = "Deployed" ]; then
    pass "CloudFront distribution '$CLOUDFRONT_ID' status: $CF_STATUS"
  else
    fail "CloudFront distribution status: $CF_STATUS (expected: Deployed)"
  fi

  # CloudFront OAC
  OAC_ID=$(aws cloudfront get-distribution-config --id "$CLOUDFRONT_ID" \
    --query 'DistributionConfig.Origins.Items[0].OriginAccessControlId' \
    --output text 2>/dev/null || echo "")
  if [ "$OAC_ID" != "" ] && [ "$OAC_ID" != "None" ]; then
    pass "CloudFront uses Origin Access Control: $OAC_ID"
  else
    fail "CloudFront does not use Origin Access Control"
  fi

  # CloudFront viewer protocol policy
  PROTOCOL=$(aws cloudfront get-distribution-config --id "$CLOUDFRONT_ID" \
    --query 'DistributionConfig.DefaultCacheBehavior.ViewerProtocolPolicy' \
    --output text 2>/dev/null || echo "")
  if [ "$PROTOCOL" = "redirect-to-https" ]; then
    pass "CloudFront enforces HTTPS redirect"
  else
    fail "CloudFront viewer protocol: $PROTOCOL (expected: redirect-to-https)"
  fi

  # CloudFront aliases
  ALIAS=$(aws cloudfront get-distribution-config --id "$CLOUDFRONT_ID" \
    --query 'DistributionConfig.Aliases.Items[0]' \
    --output text 2>/dev/null || echo "")
  if [ "$ALIAS" = "$EXPECTED_DOMAIN" ]; then
    pass "CloudFront alias matches domain: $ALIAS"
  else
    fail "CloudFront alias '$ALIAS' does not match expected '$EXPECTED_DOMAIN'"
  fi

  # CloudFront SSL certificate
  CERT_ARN=$(aws cloudfront get-distribution-config --id "$CLOUDFRONT_ID" \
    --query 'DistributionConfig.ViewerCertificate.ACMCertificateArn' \
    --output text 2>/dev/null || echo "")
  if [ "$CERT_ARN" != "" ] && [ "$CERT_ARN" != "None" ]; then
    pass "CloudFront uses ACM certificate"
  else
    fail "CloudFront does not have ACM certificate configured"
  fi
fi

# --- Website Availability ---
if curl -sf "https://$EXPECTED_DOMAIN" > /dev/null 2>&1; then
  pass "Website at https://$EXPECTED_DOMAIN is responding"
else
  fail "Website at https://$EXPECTED_DOMAIN not responding"
fi

# HTTPS redirect
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "http://$EXPECTED_DOMAIN" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
  pass "HTTP redirects to HTTPS (HTTP $HTTP_CODE)"
else
  fail "HTTP redirect returned HTTP $HTTP_CODE (expected: 301 or 302)"
fi

# --- ACM Certificate ---
if [ "$CERT_ARN" != "" ] && [ "$CERT_ARN" != "None" ]; then
  CERT_STATUS=$(aws acm describe-certificate --certificate-arn "$CERT_ARN" \
    --query 'Certificate.Status' --output text 2>/dev/null || echo "UNKNOWN")
  if [ "$CERT_STATUS" = "ISSUED" ]; then
    pass "ACM certificate status: $CERT_STATUS"
  else
    fail "ACM certificate status: $CERT_STATUS (expected: ISSUED)"
  fi
fi

echo ""
echo "=== Deployment Summary ==="
echo "  - Domain: ${EXPECTED_DOMAIN}"
echo "  - S3 Bucket: ${S3_BUCKET}"
echo "  - CloudFront: ${CLOUDFRONT_ID}"
echo "  - Index Document: ${INDEX_DOC:-unknown}"
echo "  - Errors: ${ERRORS}"
echo "  - Status: $([ "$ERRORS" -eq 0 ] && echo 'Deployed and validated' || echo 'Validation failed')"

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
