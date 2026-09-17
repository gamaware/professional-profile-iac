---
name: validate
description: >-
  Run all local validation checks: terraform fmt, validate, tflint,
  shellcheck, markdownlint, and yamllint. Use before committing or
  to verify changes pass all checks without running the full pre-commit suite.
disable-model-invocation: true
user-invocable: true
argument-hint: "[optional: 'tf', 'shell', 'md', 'yaml' to run only that category]"
---

# Validate — Local Quality Checks

Run all validation checks locally. Optionally filter by category.

## Categories

If `$ARGUMENTS` is provided, run only the matching category. Otherwise
run all categories in order.

### tf — Terraform

```bash
cd "$CLAUDE_PROJECT_DIR/terraform/website"
terraform fmt -check -recursive
terraform validate
tflint --recursive
```

### shell — Shell scripts

```bash
cd "$CLAUDE_PROJECT_DIR"
find .github/scripts .claude/hooks -name '*.sh' -exec shellcheck -S warning {} +
find .github/scripts .claude/hooks -name '*.sh' -exec shellharden --check {} +
```

### md — Markdown

```bash
cd "$CLAUDE_PROJECT_DIR"
markdownlint '**/*.md' --ignore 'terraform/website/modules/*/README.md'
```

### yaml — YAML

```bash
cd "$CLAUDE_PROJECT_DIR"
yamllint -c .yamllint.yml .
```

## Reporting

- Run each category and collect results.
- At the end, print a summary showing pass/fail per category.
- If any check failed, show the specific errors so they can be fixed.
