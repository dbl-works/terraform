# Terraform Module: Stack

This is our stack convention which brings all modules together. It can be used to bring a whole environment online quickly.



## Usage

```terraform
module "stack" {
  source = "github.com/dbl-works/terraform//stack?ref=v2021.07.05"

  account_id  = local.account_id
  project     = local.project
  environment = local.environment

  # optional
  allowlisted_ssh_ips = [
    "XX.XX.XX.XX/32", # e.g. a VPN
  ]
  region = "eu-central-1"
  cidr_block = "10.1.0.0/16"
}
```
