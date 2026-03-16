# GitHub Variables Setup

Configuration guide for GitHub Variables used by Terraform CI/CD workflows.

## Required Variables

| Variable Name | Description | Example |
| --- | --- | --- |
| `TF_VAR_aws_region` | AWS Region | `us-east-1` |

> `TF_VAR_` prefixed variables are passed to Terraform as input variables.

## Setup via GitHub CLI

```bash
gh variable set TF_VAR_aws_region --body "us-east-1"
```

**Verify variables:**

```bash
gh variable list
```

## Setup via GitHub UI

1. Navigate to repository Settings > Variables > Actions
2. Click "New repository variable"
3. **Name:** `TF_VAR_aws_region` | **Value:** `us-east-1`

## Required Secrets

| Secret Name | Description |
| --- | --- |
| `AWS_ROLE_ARN` | IAM role ARN for OIDC authentication |

```bash
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubActions-ProfessionalProfileIaC"
```

## Required Environments

| Environment | Purpose | Reviewers |
| --- | --- | --- |
| `production` | Manual approval gate for terraform apply/destroy | Repository owner |

Create via GitHub UI: Settings > Environments > New environment > `production`
