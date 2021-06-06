# Terraform Module: VPC

Creates a VPC in AWS account. Also generates a group fo public and private submodules.


## Usage

```
module "kms-key" {
  source = "https://github.com/dbl-works/terraform//kms-key"

  # Required
  environment = "staging"
  project = "someproject"
  alias = "rds"
  description = "Used for ecrypting databases and their backups"

  # Optional
  deletion_window_in_days = 30
}
```
