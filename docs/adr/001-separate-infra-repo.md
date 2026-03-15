# ADR-001: Separate Infrastructure Repository

## Status

Accepted

## Context

The professional profile website needs AWS infrastructure (S3, CloudFront,
Route 53, ACM). The question was whether to keep Terraform code in the same
repo as the website content or in a separate repository.

## Decision

Use a separate repository (`professional-profile-iac`) for infrastructure,
keeping the website content in `professional-profile-site`.

## Consequences

- Clear separation of concerns between content and infrastructure
- Independent CI/CD pipelines for each concern
- Terraform state and plan changes don't clutter the content repo
- Infrastructure can be managed independently of content updates
- Content deploys (S3 sync) can happen without infrastructure changes
- Slightly more repos to manage, but each has a focused purpose
