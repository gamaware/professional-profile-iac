# Architecture

## Infrastructure Overview

The professional profile website at `alexgarcia.info` runs on a fully
managed AWS static site stack:

```mermaid
flowchart LR
    User([Visitor]) -->|HTTPS| R53[Route 53<br/>alexgarcia.info]
    R53 --> CF[CloudFront<br/>HTTPS + HTTP/3<br/>OAC]
    CF -->|Origin Access<br/>Control| S3[S3 Bucket<br/>alexgarcia.info<br/>Private]
    ACM[ACM<br/>SSL Certificate] -.->|TLS 1.2| CF
```

## Security Architecture

Traffic flows through multiple security layers:

1. **DNS**: Route 53 managed hosted zone
2. **CDN**: CloudFront with HTTPS redirect, TLS 1.2 minimum
3. **Origin**: S3 bucket fully private, accessible only via CloudFront OAC
4. **Certificate**: ACM-managed SSL/TLS certificate

## CI/CD Pipeline

```mermaid
flowchart TB
    Dev([Developer]) --> Branch[Feature Branch]
    Branch --> PR[Pull Request]

    subgraph PR_Checks[PR Checks]
        Lint[TFLint + Checkov]
        Security[Semgrep + Trivy]
        Plan[Terraform Plan]
        Cost[Infracost]
        CR[CodeRabbit]
        Copilot[Copilot]
    end

    PR --> PR_Checks

    subgraph Deploy[Merge to Main]
        TFPlan[Terraform Plan] --> Gate{Production<br/>Approval}
        Gate --> Apply[Terraform Apply]
        Apply --> Validate[Post-Deploy<br/>Validation]
    end

    PR_Checks --> Merge[Squash Merge]
    Merge --> Deploy
```

## Drift Detection

```mermaid
flowchart LR
    Cron([Daily 9 AM UTC]) --> Plan[Terraform Plan]
    Plan -->|No Changes| OK([No Drift])
    Plan -->|Changes Found| Issue[Create GitHub Issue]
```

## Authentication

GitHub Actions authenticates to AWS via OIDC (OpenID Connect):

- No long-lived credentials stored in GitHub
- IAM role scoped to website resources only
- Trust policy restricts to this repository
- Tokens expire automatically

## Terraform State

- **Bucket**: `terraform-state-professional-profile-<ACCOUNT_ID>`
- **Encryption**: AES-256 at rest
- **Versioning**: Enabled for state recovery
- **Locking**: Native S3 lockfile
- **Public access**: Fully blocked
