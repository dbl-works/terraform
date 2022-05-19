# Terraform Module: kms-key

Encryption keys for securing various AWS resources.



## Usage

```terraform
module "kms-key" {
  source = "github.com/dbl-works/terraform//kms-key?ref=v2021.07.01"

  # Required
  environment = "staging"
  project     = "someproject"
  alias       = "rds"
  description = "Used for ecrypting databases and their backups"

  # Optional
  deletion_window_in_days = 30
}
```
