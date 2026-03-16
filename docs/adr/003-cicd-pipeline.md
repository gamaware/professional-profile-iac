# ADR-003: CI/CD Pipeline Design

## Status

Accepted

## Context

Infrastructure changes need automated validation, planning, and controlled
deployment with approval gates to prevent accidental modifications.

## Decision

Implement a multi-stage CI/CD pipeline with GitHub Actions:

1. **PR stage**: Lint (TFLint, Checkov), security scan (Semgrep, Trivy),
   terraform plan with PR comment, Infracost cost estimate
2. **Merge stage**: Plan, then apply with production environment approval gate
3. **Post-deploy**: Deterministic validation (S3, CloudFront, website health)
4. **Scheduled**: Daily drift detection with automatic issue creation

Use composite actions for reusability and external scripts for testability.

## Consequences

- All infrastructure changes are reviewed before apply
- Production environment gate prevents automatic deployment
- Post-deploy validation catches deployment issues immediately
- Drift detection alerts on manual console changes
- Scripts in `.github/scripts/` are testable independently of workflows
