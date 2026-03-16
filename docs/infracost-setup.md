# Infracost Setup Guide

Infracost provides cost estimates for Terraform changes on pull requests.
This project uses the free open-source CLI with a free API key.

## Prerequisites

- [Infracost CLI](https://www.infracost.io/docs/#quick-start) installed locally
- GitHub repository with Actions enabled

## Step 1: Install Infracost CLI

```bash
brew install infracost
```

## Step 2: Get a Free API Key

```bash
infracost auth login
```

This opens a browser to authenticate. The key is saved locally.

Retrieve the key:

```bash
infracost configure get api_key
```

The API key is free, has no expiration, and no usage limits. It fetches
AWS pricing data from the Infracost Cloud Pricing API.

## Step 3: Add Key to GitHub Secrets

```bash
gh secret set INFRACOST_API_KEY \
  --repo gamaware/professional-profile-iac \
  --body "YOUR_API_KEY"
```

## Step 4: Verify

Create a PR with a `.tf` change. The `Infracost Cost Estimate` job in
`terraform-pr.yml` will:

1. Run `infracost breakdown` on `terraform/website/`
2. Post a cost comment on the PR
3. Post a step summary with resource count and monthly cost

## How It Works

- **On every PR** with `terraform/**` changes, the Infracost job runs
- It generates a JSON cost breakdown of all Terraform resources
- The `infracost comment github` CLI command posts the results as a
  PR comment (updates existing comment on subsequent pushes)
- Resources with usage-based pricing show per-unit costs
- Resources with fixed monthly costs show exact amounts

## Local Usage

```bash
# Full breakdown
infracost breakdown --path=terraform/website

# JSON output
infracost breakdown --path=terraform/website --format=json

# Compare two branches
infracost diff --path=terraform/website
```

## Cost

Infracost CLI and API key are **free forever** (Apache 2.0 open-source).
No dashboard or cloud subscription is needed. The API key only fetches
public cloud pricing data.

## References

- [Infracost Documentation](https://www.infracost.io/docs/)
- [Infracost GitHub Actions](https://github.com/infracost/actions)
- [Supported Resources](https://www.infracost.io/docs/supported_resources/)
