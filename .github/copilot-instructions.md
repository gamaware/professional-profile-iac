# Copilot Code Review Instructions

This repository manages AWS infrastructure for a static website using Terraform.
It provisions S3, CloudFront, Route 53, and ACM resources.

## Review priorities

1. **Security** — Flag any hardcoded credentials, AWS account IDs, or secrets.
   All sensitive values must use variables or data sources.

2. **Terraform best practices** — Proper use of modules, variables, outputs,
   data sources, and resource naming conventions.

3. **State management** — Ensure state backend is properly configured with
   encryption and locking.

4. **Cost awareness** — Flag any resources that may incur unexpected costs.
   This is a personal account with minimal budget.

5. **Least privilege** — IAM policies and roles should follow least-privilege
   principles.

6. **Markdown quality** — 120-char limit (tables exempt), fenced code blocks,
   ATX headings.
