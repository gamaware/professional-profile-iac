# ADR-005: Defense in Depth

## Status

Accepted

## Context

A single layer of security is insufficient. Multiple complementary layers
catch different types of issues at different stages.

## Decision

Implement security checks at every stage:

1. **Pre-commit**: detect-secrets, gitleaks, shellcheck, shellharden,
   terraform_validate, terraform_tflint, terraform_trivy, terraform_checkov
2. **PR CI**: Semgrep SAST, Trivy IaC scanning, TFLint, Checkov, zizmor
3. **Merge CI**: Terraform plan review, production approval gate
4. **Post-deploy**: Infrastructure validation (S3, CloudFront, HTTPS)
5. **Scheduled**: Daily drift detection
6. **Code review**: CodeRabbit (auto), Copilot (auto), human (required)

## Consequences

- Issues caught early in the development cycle
- Multiple tools compensate for each other's blind spots
- Every change passes through at least 6 security checkpoints
- Pre-commit hooks provide immediate developer feedback
- CI catches issues that bypass local hooks
