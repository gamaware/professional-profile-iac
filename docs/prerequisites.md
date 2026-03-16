# Prerequisites

One-time setup required before deploying. Follow these guides in order:

| Step | Guide | What it does |
| --- | --- | --- |
| 1 | [GitHub OIDC Setup](github-oidc-setup.md) | OIDC provider, IAM role, policies, GitHub secret |
| 2 | [GitHub Variables Setup](github-variables-setup.md) | Set region and environment variables |
| 3 | [Infracost Setup](infracost-setup.md) | Free API key for cost estimation on PRs |
| 4 | [Local Development](#local-development) | Terraform, pre-commit hooks, AWS SSO |

## Local Development

### Install tools

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [TFLint](https://github.com/terraform-linters/tflint)
- [pre-commit](https://pre-commit.com/#install)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [Infracost](https://www.infracost.io/docs/#quick-start)
- [shellcheck](https://www.shellcheck.net/) and
  [shellharden](https://github.com/anordal/shellharden)
- [Vale](https://vale.sh/) and [gitleaks](https://github.com/gitleaks/gitleaks)
- AWS CLI v2 with SSO profile `personal`

### Setup

```bash
# Authenticate
aws sso login --profile personal

# Install pre-commit hooks
pre-commit install
vale sync

# Initialize Terraform
cd terraform/website
terraform init -backend-config="profile=personal"

# Verify
pre-commit run --all-files
terraform validate
terraform plan
```
