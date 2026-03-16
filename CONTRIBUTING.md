# Contributing

Thank you for your interest in improving this project.

## Who Can Contribute

- Infrastructure engineers who spot issues in Terraform code or CI/CD pipelines
- Security professionals who identify misconfigurations
- Anyone who finds a bug in a script or workflow

## How to Report an Issue

Open a [GitHub Issue](../../issues) describing:

- Which Terraform resource, workflow, or script is affected
- What is wrong or misconfigured
- What the correct behavior should be

## How to Submit a Fix

1. Fork the repository
2. Create a branch: `git checkout -b fix/short-description`
3. Make your changes
4. Run pre-commit hooks: `pre-commit run --all-files`
5. Open a Pull Request against `main` with a clear description of what you changed and why

## Code Guidelines

- Terraform must pass `terraform fmt`, `terraform validate`, TFLint, Checkov, and Trivy
- Shell scripts must pass ShellCheck and shellharden
- Markdown must pass markdownlint (config in `.markdownlint.yaml`)
- Commits must follow [Conventional Commits](https://www.conventionalcommits.org/)

## Questions

Reach out via email: <gamaware@gmail.com>
