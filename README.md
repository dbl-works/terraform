# DBL Terraform Modules

We create modules here for re-use between projects.



## Modules

- [cognito](cognito/README.md) - Crate user pools for use with authentication
- [kms-key](kms-key/README.md) - Encryption keys for securing various AWS resources
- [rds][rds/README.md] - Postgresql database managed by AWS
- [vpc][vpc/README.md] - Virtual Private Cloud network to contain all resources for a project/environment



## Conventions

- Use `proejct` + `environment` combination for a workspace/module context
- Use `main` for core resource identifiers. e.g. `resource "aws_rds_instance" "main" {}`


## Usage

Refer to specific module README for variables and recommended usage.

```
module "awesome-module" {
  source = "https://github.com/dbl-works/terraform//awesome-module"

  # Required
  environment = "staging"
  project = "someproject"

  # Optional
  some_variable = "some_value"
}
```
