# DBL Terraform Modules

We create modules here for re-use between projects.



## Modules

- [cdn](cdn/README.md) - All ressources required to host a simple CDN.
- [certificate](certificate/README.md) - Requests a certificate from the Amazon Certificate Manager.
- [cognito](cognito/README.md) - Create user pools for use with authentication.
- [ecr](ecr/README.md) - A reopsitory for storing built docker images.
- [ecs](ecs/README.md) - Compute cluster for running docker containers
- [kms-key](kms-key/README.md) - Encryption keys for securing various AWS resources.
- [nat](nat/README.md) - A reopsitory for setting up a network address translation (NAT).
- [rds](rds/README.md) - Used for creating and configuring databases and their networking.
- [secrets](secrets/README.md) - Used for creating a new secret.
- [vpc](vpc/README.md) - Creates a VPC in AWS account. Also generates a group fo public and private submodules.



## Conventions

- Use `project` + `environment` combination for a workspace/module context
- Use `main` for core resource identifiers. e.g. `resource "aws_rds_instance" "main" {}`


## Usage

Refer to specific module README for variables and recommended usage.

```terraform
module "awesome-module" {
  source = "github.com/dbl-works/terraform//awesome-module?ref=v2021.07.05"

  # Required
  environment = "staging"
  project     = "someproject"

  # Optional
  some_variable = "some_value"
}
```
