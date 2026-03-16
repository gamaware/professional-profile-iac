#!/usr/bin/env bash
set -euo pipefail

if [ "$PLAN_EXIT_CODE" = "2" ]; then
  echo "has_drift=true" >> "$GITHUB_OUTPUT"
  echo "Configuration drift detected!"

  {
    echo "## Drift Detection"
    echo ""
    echo "Configuration drift was detected in the infrastructure."
    echo "Review the plan output and reconcile."
  } >> "$GITHUB_STEP_SUMMARY"
else
  echo "has_drift=false" >> "$GITHUB_OUTPUT"
  echo "No drift detected."

  {
    echo "## Drift Detection"
    echo ""
    echo "No configuration drift detected."
  } >> "$GITHUB_STEP_SUMMARY"
fi
