# Terraform Module: VPC

Creates a VPC in AWS account. Also generates a group fo public and private submodules.


## Usage

```
module "vpc" {
  source = "github.com/dbl-works/terraform//vpc?ref=v2021.07.05"

  account_id         = "12345678"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  environment        = "staging"
  project            = "someproject"

  # optional
  region     = "eu-central-1"
  cidr_block = "10.6.0.0/16"
}
```
