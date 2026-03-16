#!/usr/bin/env bash
set -euo pipefail

TITLE="Infrastructure drift detected"
EXISTING=$(gh issue list --label "drift" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")

BODY="## Infrastructure Drift Detected

Terraform plan detected changes that were not made through code.

**Working directory:** \`${WORKING_DIRECTORY}\`
**Detected at:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Run:** [${GITHUB_RUN_ID}](${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID})

Review the plan output in the workflow run and reconcile the drift."

if [ "$EXISTING" != "" ]; then
  gh issue comment "$EXISTING" --body "$BODY"
  echo "Updated existing drift issue #$EXISTING"
else
  gh issue create --title "$TITLE" --body "$BODY" --label "drift"
  echo "Created new drift issue"
fi
