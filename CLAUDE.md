# CLAUDE.md — Project Instructions for Claude Code

This file is automatically loaded into context when Claude Code starts a conversation
in this repository. It defines the conventions, rules, and structure that must be followed.

## Repository Overview

Terraform infrastructure for the professional profile website at `alexgarcia.info`.
Manages S3 bucket, CloudFront distribution, Route 53 DNS records, and ACM certificate.

## Repository Structure

```text
main.tf                 # Root module configuration
variables.tf            # Input variables
outputs.tf              # Output values
providers.tf            # Provider configuration
backend.tf              # State backend configuration
modules/
  static-site/          # Reusable module for S3 + CloudFront static site
    main.tf
    variables.tf
    outputs.tf
docs/
  adr/                  # Architecture Decision Records (dateless)
.claude/
  settings.json         # Project-level Claude Code settings (hooks, permissions)
  hooks/                # Automation hooks
  skills/               # Reusable skills (/ship for PR lifecycle)
.github/
  workflows/            # CI/CD pipelines (validate, plan, apply)
  ISSUE_TEMPLATE/       # Issue templates
  PULL_REQUEST_TEMPLATE.md
  copilot-instructions.md  # Copilot code review custom instructions
  dependabot.yml        # Dependabot configuration
```

## Git Workflow

### Commits

- **Conventional commits required** — enforced by `conventional-pre-commit` hook.
- Format: `type: description` (e.g., `fix:`, `feat:`, `docs:`, `chore:`, `ci:`).
- Never commit directly to `main` — enforced by `no-commit-to-branch` hook.
- Always work on a feature branch and create a PR.
- Do NOT add `Co-Authored-By` watermarks or any Claude/AI attribution to commits,
  code, or content. Ever.

### Pull Requests

- All changes go through PRs — no direct pushes to `main`.
- Squash merge only (merge commits and rebase disabled).
- CodeRabbit and GitHub Copilot auto-review all PRs — address their comments
  before merging.
- All required status checks must pass before merge.
- At least 1 approving review required (CODEOWNERS enforced).
- Use `--admin` flag to bypass branch protection when necessary.

## Terraform Conventions

- Use `terraform fmt` for formatting — enforced by pre-commit hook.
- Use `terraform validate` for syntax checking.
- Use `tflint` for best practice linting.
- Use `terraform-docs` to auto-generate module documentation.
- Provider versions must be pinned.
- Use variables for all configurable values — no hardcoded account IDs or
  resource names.
- State stored remotely in S3 with DynamoDB locking.

## Pre-commit Hooks

All hooks must pass before committing. Install with `pre-commit install`.

### Hooks in use

- **General**: trailing-whitespace, end-of-file-fixer, check-yaml, check-json,
  check-added-large-files (1MB), check-merge-conflict, detect-private-key,
  check-symlinks, check-case-conflict, no-commit-to-branch (main).
- **Secrets**: detect-secrets (with `.secrets.baseline`), gitleaks.
- **Terraform**: terraform_fmt, terraform_validate, terraform_tflint, terraform_docs.
- **Markdown**: markdownlint with `--fix`.
- **GitHub Actions**: actionlint, zizmor (security analysis).
- **Commits**: conventional-pre-commit (commit-msg stage).

## Linting Policy

### Absolute rule: NO suppressions on our own code

- All default linting rules are enforced. Fix violations, never suppress them.
- Markdownlint config: MD013 line length at 120 characters, tables exempt.

## Security

- Never commit secrets, credentials, private keys, or `.env` files.
- Never hardcode AWS account IDs — use variables or data sources.
- Terraform state may contain sensitive data — state bucket must have
  encryption enabled and public access blocked.

## Repo Configuration

- **Visibility**: Public
- **Topics**: terraform, aws, infrastructure, s3, cloudfront, route53, iac
- **Merge strategy**: Squash only, PR title used as commit title
- **Auto merge**: Enabled
- **Delete branch on merge**: Enabled
- **Wiki**: Disabled
- **Projects**: Disabled
