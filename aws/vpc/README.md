# Terraform Module: VPC

Creates a VPC in AWS account. Also generates a group of public and private subnets.



## Usage

```terraform
module "vpc" {
  source = "github.com/dbl-works/terraform//aws/vpc?ref=main"

  account_id         = "12345678"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  environment        = "staging"

  # optional
  cidr_block = "10.0.0.0/16"
}
```
