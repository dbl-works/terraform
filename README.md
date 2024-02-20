# DBL Terraform Modules

We create modules here for re-use between projects.

## Modules

- [aws](aws/README.md) - Terraform modules for Amazon Web Services (AWS).
- [azure](azure/README.md) - Terraform modules for Microsoft Azure.
- [snowflake-cloud](snowflake/cloud/README.md) - Manage a Snowflake Cloud account

## Conventions

- Use `project` + `environment` combination for a workspace/module context
- Use `main` for core resource identifiers. e.g. `resource "aws_rds_instance" "main" {}`

## Usage

Refer to specific module README for variables and recommended usage.

```terraform
module "awesome-module" {
  source = "github.com/dbl-works/terraform//aws/awesome-module?ref=v2021.07.05"

  # Required
  environment = "staging"
  project     = "someproject"

  # Optional
  some_variable = "some_value"
}
```
