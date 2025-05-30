# Terraform Module: NAT

A repository for setting up network address translation (NAT).

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

## How it Works

- Creates one NAT Gateway per Elastic IP provided
- Creates one route table per private subnet
- If you have more private subnets than NAT Gateways, the module cycles through available NAT Gateways
  - Example: 3 private subnets with 2 NAT Gateways means the 3rd subnet uses the 1st NAT Gateway

## Compatibility

This module supports dynamic subnet creation. The route table associations use indices as keys to avoid Terraform errors when creating new subnets.

## Outputs
* `aws_route_table_ids` for VPC-Peering
