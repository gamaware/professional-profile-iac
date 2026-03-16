#!/usr/bin/env bash
set -euo pipefail

# Run terraform plan with detailed exit code and save output
set +e
terraform plan -detailed-exitcode -no-color -out=tfplan 2>&1 | tee plan.txt
EXIT_CODE=$?
set -e

if [ "$EXIT_CODE" -eq 1 ]; then
  echo "Terraform plan failed"
  exit 1
fi

# Post step summary
{
  echo "## Terraform Plan"
  echo ""
  if [ "$EXIT_CODE" -eq 0 ]; then
    echo "No changes. Infrastructure is up-to-date."
  elif [ "$EXIT_CODE" -eq 2 ]; then
    ADDS=$(grep -c "will be created" plan.txt || true)
    CHANGES=$(grep -c "will be updated" plan.txt || true)
    DESTROYS=$(grep -c "will be destroyed" plan.txt || true)
    echo "| Action | Count |"
    echo "| --- | --- |"
    echo "| Add | $ADDS |"
    echo "| Change | $CHANGES |"
    echo "| Destroy | $DESTROYS |"
  fi
} >> "$GITHUB_STEP_SUMMARY"

echo "Terraform plan completed (exit code: $EXIT_CODE)"
