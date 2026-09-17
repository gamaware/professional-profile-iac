---
name: tf-test
description: >-
  Run native terraform tests locally with automatic backend override
  handling. Use when the user wants to run terraform tests, validate
  module behavior, or check test results before pushing.
disable-model-invocation: true
user-invocable: true
argument-hint: "[optional test filter, e.g. 'variable_validation']"
---

# Terraform Test — Local Native Tests

Run Terraform's native test framework with mocked providers. Handles the
backend override automatically (create, init, test, cleanup).

## Steps

1. `cd` to `$CLAUDE_PROJECT_DIR/terraform/website`.

2. Create the backend override file:

   ```bash
   printf 'terraform {\n  backend "local" {}\n}\n' > backend_override.tf
   ```

3. Initialize with the local backend:

   ```bash
   terraform init -reconfigure
   ```

4. Run the tests. If `$ARGUMENTS` is provided, use it as a filter:

   ```bash
   # No arguments — run all tests
   terraform test -verbose

   # With filter argument
   terraform test -verbose -filter=tests/$ARGUMENTS.tftest.hcl
   ```

5. **Always clean up**, even if tests fail, and restore the declared S3
   backend so later `plan`/`apply` runs do not fail on a backend change:

   ```bash
   rm -f backend_override.tf
   terraform init -reconfigure -input=false -backend-config="profile=personal"
   ```

6. Report results. If any test failed, show the failing assertions and
   the relevant test file for context.
