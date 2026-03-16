# Professional Profile — Infrastructure

![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20CloudFront%20%7C%20Route53-FF9900?logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D%201.5-7B42BC?logo=terraform)
![IaC](https://img.shields.io/badge/IaC-Managed-blue)

Terraform infrastructure for the professional profile website at
[alexgarcia.info](https://alexgarcia.info).

## Architecture

- **S3**: Static website hosting bucket (private, CloudFront OAC access only)
- **CloudFront**: CDN with HTTPS redirect, HTTP/2+3, custom error pages, OAC
- **Route 53**: DNS management for `alexgarcia.info`
- **ACM**: SSL/TLS certificate (us-east-1)

See [docs/architecture.md](docs/architecture.md) for detailed diagrams and
security architecture.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [TFLint](https://github.com/terraform-linters/tflint)
- [pre-commit](https://pre-commit.com/#install)
- [Trivy](https://aquasecurity.github.io/trivy/)
- [shellcheck](https://www.shellcheck.net/) and
  [shellharden](https://github.com/anordal/shellharden)
- [Vale](https://vale.sh/) and [gitleaks](https://github.com/gitleaks/gitleaks)
- AWS CLI v2 configured with SSO profile `personal`

## Getting Started

1. **Complete prerequisites**: See [docs/prerequisites.md](docs/prerequisites.md)
2. **Set up GitHub OIDC**: See
   [docs/github-oidc-setup.md](docs/github-oidc-setup.md)
3. **Configure GitHub variables**: See
   [docs/github-variables-setup.md](docs/github-variables-setup.md)
4. **Create `terraform.tfvars`** from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit with your values (aws_profile = "personal")
```

## Local Development Setup

```bash
# 1. Authenticate
aws sso login --profile personal

# 2. Install pre-commit hooks (26 checks)
pre-commit install
vale sync

# 3. Initialize Terraform
terraform init -backend-config="profile=personal"

# 4. Verify
pre-commit run --all-files
terraform validate
terraform plan
```

## Development Workflow

```text
1. Create feature branch
2. Make changes
3. Pre-commit hooks validate automatically (26 checks)
4. Push and create PR
5. CI validates: lint, security, plan, cost, reviews
6. Squash merge after approval
7. CI runs: plan -> approval gate -> apply -> validation
```

## Repository Structure

```text
main.tf                         # Root module configuration
variables.tf                    # Input variables
outputs.tf                      # Output values
providers.tf                    # Provider configuration
backend.tf                      # S3 state backend
terraform.tfvars.example        # Variable template
modules/
  static-site/                  # S3 + CloudFront + Route 53 module
    main.tf
    variables.tf
    outputs.tf
    .terraform-docs.yml         # Auto-doc generation config
docs/
  architecture.md               # Architecture and security design
  adr/                          # Architecture Decision Records (5)
  github-oidc-setup.md          # OIDC authentication guide
  github-variables-setup.md     # GitHub variables guide
  prerequisites.md              # Setup prerequisites
.claude/
  settings.json                 # Claude Code hooks config
  hooks/                        # Post-edit and protect hooks
  skills/ship/                  # /ship PR lifecycle skill
.github/
  actions/                      # Composite actions (5)
  scripts/                      # Shell scripts (7)
  workflows/                    # CI/CD pipelines (6)
  ISSUE_TEMPLATE/               # Issue templates
  PULL_REQUEST_TEMPLATE.md
  copilot-instructions.md
  dependabot.yml
```

## CI/CD Pipeline

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `terraform-pr.yml` | PR with `.tf` changes | Lint, security, plan, cost estimate |
| `terraform-cicd.yml` | Push to main | Plan, approval gate, apply, validation |
| `drift-detection.yml` | Daily 9 AM UTC | Detect infrastructure drift |
| `quality-checks.yml` | Every PR and push | Markdown, YAML, shell, prose, zizmor |
| `security.yml` | Every PR and push | Semgrep SAST + Trivy IaC scan |
| `update-pre-commit-hooks.yml` | Weekly (Sunday) | Auto-update hook versions |

## Authentication

GitHub Actions authenticates via OIDC — no static credentials:

- **IAM Role**: `GitHubActions-ProfessionalProfileIaC`
- **Policies**: WebsiteInfraManagement (scoped), TerraformStateAccess
- **Trust**: Restricted to `repo:gamaware/professional-profile-iac:*`

## Quick Links

| Resource | Link |
| --- | --- |
| Architecture | [docs/architecture.md](docs/architecture.md) |
| ADRs | [docs/adr/](docs/adr/README.md) |
| OIDC Setup | [docs/github-oidc-setup.md](docs/github-oidc-setup.md) |
| Prerequisites | [docs/prerequisites.md](docs/prerequisites.md) |
| Site Repo | [professional-profile-site](https://github.com/gamaware/professional-profile-site) |

## Author

Alex Garcia — [gamaware@gmail.com](mailto:gamaware@gmail.com)

## License

[MIT](LICENSE)
