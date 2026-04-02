# ADR-006: Terraform Testing Strategy

## Status

Accepted

## Context

The website Terraform module had zero automated tests. Validation relied on
post-deploy shell scripts (validate-deployment.sh) and CI linting (TFLint,
Checkov, terraform fmt, terraform validate). Configuration logic errors were
only caught after apply, and there was no assertion-based testing of resource
properties or module outputs.

## Decision

Adopt a two-tier testing strategy:

1. **terraform test** (native, mocked providers) — Unit-level configuration
   assertions that run without AWS credentials. Tests variable defaults,
   resource properties (S3, CloudFront, Route53), and output values. Uses
   mock_provider blocks (Terraform 1.7+) for fast, isolated execution.
   Integrated into terraform-pr.yml as a parallel job.

2. **Terratest** (Go, AWS SDK v2) — Read-only post-deploy integration tests
   that verify deployed infrastructure matches expectations. Does NOT call
   InitAndApply; instead reads Terraform outputs and validates via AWS SDK
   calls (S3, CloudFront, Route53, ACM, HTTP health). Integrated into
   terraform-cicd.yml after terraform apply.

## Consequences

- Faster feedback: configuration issues caught at PR time, not after apply
- Two languages: HCL for unit tests, Go for integration tests
- Go dependency added to CI (tests/ directory with go.mod)
- Mock provider maintenance: mock defaults may need updates when resources change
- Existing validate-deployment.sh continues running alongside Terratest
