# Prerequisites

One-time setup required before deploying. Follow these guides in order:

| Step | Guide | What it does |
| --- | --- | --- |
| 1 | [GitHub OIDC Setup](github-oidc-setup.md) | OIDC provider, IAM role, policies, GitHub secret |
| 2 | [Local Development](#local-development) | Terraform, pre-commit hooks, AWS SSO |

## Local Development

### Install tools

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [pre-commit](https://pre-commit.com/#install)
- [TFLint](https://github.com/terraform-linters/tflint)
- AWS CLI v2 with SSO profile `personal`

### Setup

```bash
# Authenticate
aws sso login --profile personal

# Install pre-commit hooks
pre-commit install

# Initialize Terraform
terraform init

# Verify
terraform validate
```
