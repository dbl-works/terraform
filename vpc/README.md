# Terraform Module: VPC

Creates a VPC in AWS account. Also generates a group fo public and private submodules.


## Usage

```
module "vpc" {
  source = "https://github.com/dbl-works/terraform//vpc"

  account_id = "12345678"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  cidr_block = "10.6.0.0/16"
  environment = "staging"
  project = "someproject"
}
```
