# ADR-004: IAM Least Privilege for CI/CD

## Status

Accepted

## Context

GitHub Actions needs AWS access to run Terraform plan and apply. Using
broad permissions like `AdministratorAccess` violates least privilege
and increases blast radius if credentials are compromised.

## Decision

Use OIDC authentication with scoped inline policies:

- **WebsiteInfraManagement**: S3 (full, scoped to `alexgarcia.info` bucket),
  CloudFront (full), ACM (read-only), Route 53 (read-only)
- **TerraformStateAccess**: S3 access scoped to the state bucket only
- Trust policy restricts to `repo:gamaware/professional-profile-iac:*`

No long-lived credentials. OIDC tokens expire automatically.

## Consequences

- CI/CD can only modify website infrastructure resources
- Cannot accidentally affect other AWS resources
- ACM and Route 53 are read-only (managed manually or by other repos)
- Adding new resource types requires updating the IAM policy
- OIDC eliminates credential rotation burden
