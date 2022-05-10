# Terraform Module: NAT

A repository for setting up a network address translation (NAT).


## Usage

```terraform
module "nat" {
  source = "github.com/dbl-works/terraform//nat?ref=v2021.07.12"

  project            = "my-project"
  environment        = "production"
  vpc_id             = module.vpc.id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids
  public_ips = [
    "123.123.123.123",
    "234.234.234.234",
    "134.134.134.134",
  ]
}
```

`public_ips` is a list of Elastic IPs that have to belong to the same AWS account that hosts the NAT.



## Outputs

_none_
