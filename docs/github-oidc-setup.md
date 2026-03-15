# GitHub Actions OIDC Setup Guide

Setup guide for OpenID Connect (OIDC) authentication allowing GitHub Actions
to access AWS without storing long-lived credentials.

## Prerequisites

- AWS CLI configured with SSO profile `personal`
- GitHub repository created
- AWS account ID: replace `YOUR_AWS_ACCOUNT_ID` throughout

## Step 1: Create OIDC Identity Provider (One-time per account)

```bash
aws iam create-open-id-connect-provider \
  --profile personal \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

Verify:

```bash
aws iam list-open-id-connect-providers --profile personal
```

## Step 2: Create IAM Role with Trust Policy

```bash
aws iam create-role \
  --profile personal \
  --role-name GitHubActions-ProfessionalProfileIaC \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
          "StringLike": {
            "token.actions.githubusercontent.com:sub": "repo:gamaware/professional-profile-iac:*"
          }
        }
      }
    ]
  }' \
  --description "Role for GitHub Actions to manage website infrastructure"
```

## Step 3: Add Website Infrastructure Policy

Scoped to S3, CloudFront, ACM (read-only), and Route 53 (read-only):

```bash
aws iam put-role-policy \
  --profile personal \
  --role-name GitHubActions-ProfessionalProfileIaC \
  --policy-name WebsiteInfraManagement \
  --policy-document file://docs/policies/website-infra-management.json
```

## Step 4: Add Terraform State Access Policy

```bash
aws iam put-role-policy \
  --profile personal \
  --role-name GitHubActions-ProfessionalProfileIaC \
  --policy-name TerraformStateAccess \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::terraform-state-professional-profile-YOUR_AWS_ACCOUNT_ID",
          "arn:aws:s3:::terraform-state-professional-profile-YOUR_AWS_ACCOUNT_ID/*"
        ]
      }
    ]
  }'
```

## Step 5: Add Role ARN to GitHub Secrets

```bash
gh secret set AWS_ROLE_ARN \
  --repo gamaware/professional-profile-iac \
  --body "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubActions-ProfessionalProfileIaC"
```

## Step 6: Set GitHub Variables

```bash
gh variable set TF_VAR_aws_region \
  --repo gamaware/professional-profile-iac \
  --body "us-east-1"
```

## Step 7: Create Production Environment

Create a `production` environment in GitHub with manual approval gate
(Settings > Environments > New environment).

## Configuration Summary

1. **OIDC Provider**: `token.actions.githubusercontent.com` (shared across repos)
2. **IAM Role**: `GitHubActions-ProfessionalProfileIaC`
   - Inline policy: `WebsiteInfraManagement` (S3, CloudFront, ACM, Route 53)
   - Inline policy: `TerraformStateAccess` (state bucket)
3. **GitHub Secret**: `AWS_ROLE_ARN`
4. **GitHub Variable**: `TF_VAR_aws_region`
5. **Environment**: `production` (manual approval gate)

## Security

- Least privilege: scoped to website resources only
- Repository restriction: trust policy limits to `gamaware/professional-profile-iac`
- No long-lived credentials: OIDC tokens expire automatically
- ACM and Route 53: read-only (managed manually or by other repos)
