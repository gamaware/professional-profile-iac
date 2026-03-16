#!/usr/bin/env bash
set -euo pipefail

# Post-destroy validation via AWS CLI
# Required env vars: EXPECTED_DOMAIN

fail() { echo "FAIL: $1"; }
pass() { echo "PASS: $1"; }

echo "=== Post-Destroy Validation ==="
echo ""

# Verify S3 bucket no longer exists
if aws s3api head-bucket --bucket "$EXPECTED_DOMAIN" 2>/dev/null; then
  fail "S3 bucket '$EXPECTED_DOMAIN' still exists"
else
  pass "S3 bucket '$EXPECTED_DOMAIN' has been removed"
fi

# Verify CloudFront distribution no longer exists
DIST_COUNT=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Aliases.Items[0]=='$EXPECTED_DOMAIN'] | length(@)" \
  --output text 2>/dev/null || echo "0")
if [ "$DIST_COUNT" = "0" ]; then
  pass "No CloudFront distribution found for $EXPECTED_DOMAIN"
else
  fail "CloudFront distribution for $EXPECTED_DOMAIN still exists"
fi

# Verify Route 53 A record no longer exists
ZONE_ID=$(aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='${EXPECTED_DOMAIN}.'].Id" \
  --output text 2>/dev/null || echo "")
if [ "$ZONE_ID" != "" ]; then
  A_RECORD=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --query "ResourceRecordSets[?Name=='${EXPECTED_DOMAIN}.' && Type=='A'].Name" \
    --output text 2>/dev/null || echo "")
  if [ "$A_RECORD" = "" ]; then
    pass "Route 53 A record for $EXPECTED_DOMAIN has been removed"
  else
    fail "Route 53 A record for $EXPECTED_DOMAIN still exists"
  fi
else
  pass "No hosted zone found for $EXPECTED_DOMAIN"
fi

# Verify website no longer responds
if curl -sf "https://$EXPECTED_DOMAIN" > /dev/null 2>&1; then
  fail "Website at https://$EXPECTED_DOMAIN still responding"
else
  pass "Website at https://$EXPECTED_DOMAIN no longer responding"
fi

echo ""
echo "=== Destroy Validation Complete ==="
