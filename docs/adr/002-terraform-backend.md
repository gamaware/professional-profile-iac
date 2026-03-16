# ADR-002: Terraform Backend Configuration

## Status

Accepted

## Context

Terraform state must be stored remotely for CI/CD pipelines and to prevent
local state drift. The state may contain sensitive resource attributes.

## Decision

Use an S3 backend with:

- Dedicated bucket per project (`terraform-state-professional-profile-<account-id>`)
- Versioning enabled for state recovery
- AES-256 encryption at rest
- Public access fully blocked
- Native S3 lockfile for concurrent access prevention
- Backend profile passed via `-backend-config` for local use, OIDC env vars for CI

## Consequences

- State is durable and recoverable via S3 versioning
- Encryption protects sensitive attributes in state
- No DynamoDB table needed (native locking via S3)
- Local development requires `terraform init -backend-config="profile=personal"`
- CI uses OIDC credentials automatically via environment variables
