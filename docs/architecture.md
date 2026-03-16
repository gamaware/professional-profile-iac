# Architecture

## Infrastructure Overview

The professional profile website at `alexgarcia.info` runs on a fully
managed AWS static site stack:

```text
                    +------------------+
                    |   Route 53       |
                    |  alexgarcia.info |
                    +--------+---------+
                             |
                             | A Record (alias)
                             v
                    +------------------+
                    |   CloudFront     |
                    |  E101E3TIVDODKY  |
                    |  HTTPS + HTTP/3  |
                    |  OAC Auth        |
                    +--------+---------+
                             |
                             | Origin Access Control
                             v
                    +------------------+
                    |   S3 Bucket      |
                    |  alexgarcia.info |
                    |  Private         |
                    +------------------+

                    +------------------+
                    |   ACM            |
                    |  SSL Certificate |
                    |  (us-east-1)     |
                    +------------------+
```

## Security Architecture

Traffic flows through multiple security layers:

1. **DNS**: Route 53 managed hosted zone
2. **CDN**: CloudFront with HTTPS redirect, TLS 1.2 minimum
3. **Origin**: S3 bucket fully private, accessible only via CloudFront OAC
4. **Certificate**: ACM-managed SSL/TLS certificate

## CI/CD Pipeline

```text
Developer
    |
    v
Feature Branch --> PR Created
    |
    +-- Quality Checks (8 jobs)
    +-- Security Scanning (Semgrep + Trivy)
    +-- Terraform Lint + Security (TFLint + Checkov)
    +-- Terraform Plan (OIDC, posted as PR comment)
    +-- Infracost (cost estimation)
    +-- CodeRabbit Review
    +-- Copilot Review
    |
    v
Squash Merge to main
    |
    +-- Terraform Plan
    +-- Production Approval Gate (manual)
    +-- Terraform Apply
    +-- Post-Deployment Validation
        +-- S3 bucket exists
        +-- CloudFront deployed
        +-- Website responds (HTTPS)
        +-- HTTP redirects to HTTPS
```

## Drift Detection

Daily at 9 AM UTC, a scheduled workflow runs `terraform plan` against
live infrastructure. If drift is detected, a GitHub issue is created
automatically.

## Authentication

GitHub Actions authenticates to AWS via OIDC (OpenID Connect):

- No long-lived credentials stored in GitHub
- IAM role scoped to website resources only
- Trust policy restricts to this repository
- Tokens expire automatically

## Terraform State

- **Bucket**: `terraform-state-professional-profile-<account-id>`
- **Encryption**: AES-256 at rest
- **Versioning**: Enabled for state recovery
- **Locking**: Native S3 lockfile
- **Public access**: Fully blocked
