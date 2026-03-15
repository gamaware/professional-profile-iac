# Professional Profile — Infrastructure

Terraform infrastructure for the professional profile website at
[alexgarcia.info](https://alexgarcia.info).

## Architecture

- **S3**: Static website hosting bucket
- **CloudFront**: CDN with HTTPS, custom error pages, and compression
- **Route 53**: DNS management for `alexgarcia.info`
- **ACM**: SSL/TLS certificate

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configured with SSO profile `personal`
- Existing Route 53 hosted zone for `alexgarcia.info`
- Existing ACM certificate for `alexgarcia.info` in us-east-1

## Usage

```bash
# Authenticate
aws sso login --profile personal

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## Importing Existing Resources

The S3 bucket, CloudFront distribution, and Route 53 records already exist.
Import them before the first apply:

```bash
terraform import module.static_site.aws_s3_bucket.this alexgarcia.info
terraform import module.static_site.aws_cloudfront_distribution.this <DISTRIBUTION_ID>
```

## Repository Structure

```text
main.tf                    # Root module
variables.tf               # Input variables
outputs.tf                 # Output values
providers.tf               # AWS provider configuration
backend.tf                 # Remote state backend (S3 + DynamoDB)
modules/
  static-site/             # S3 + CloudFront + ACM module
    main.tf
    variables.tf
    outputs.tf
CLAUDE.md                  # Claude Code project instructions
.claude/                   # Claude Code hooks and skills
.github/                   # CI/CD, templates, dependabot
docs/adr/                  # Architecture Decision Records
```

## Related Repositories

- [professional-profile-site](https://github.com/gamaware/professional-profile-site) — Website content (HTML/CSS/JS)

## Author

Alex Garcia — [gamaware@gmail.com](mailto:gamaware@gmail.com)

## License

[MIT](LICENSE)
