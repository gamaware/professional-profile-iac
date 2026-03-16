#!/usr/bin/env bash
set -euo pipefail

# Run terraform plan for drift detection
set +e
terraform plan -detailed-exitcode -no-color 2>&1 | tee drift-plan.txt
EXIT_CODE=$?
set -e

echo "exit_code=$EXIT_CODE" >> "$GITHUB_OUTPUT"

# Exit code 1 = error, 2 = drift detected, 0 = no drift
if [ "$EXIT_CODE" -eq 1 ]; then
  echo "Terraform plan failed during drift detection"
  exit 1
fi
