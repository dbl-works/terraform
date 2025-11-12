# Terraform Module: RDS

Used to create a VPC peering between two VPCs.

Both VPCs may be in different geo-regions.

The VPC Peering Connection resource is created in the "accepter"'s region/account.
The default AWS provider is used for the "requester". The AWS provider for the accepter must be configured as outlined below.



:warning: Be aware, that both VPCs must use a different CIDR block!



## Usage

```terraform
# versions.tf

# Requester's credentials
provider "aws" {
  region  = "eu-central-1"
  profile = "dbl-works"
}

# Accepter's credentials
provider "aws" {
  alias = "peer"

  region  = "us-east-1"
  profile = "dbl-works"
}
```


```terraform
# main.tf

module "vpc-peering" {
  source = "github.com/dbl-works/terraform//aws/vpc-peering?ref=main"

  providers = {
    aws      = aws
    aws.peer = aws.peer
  }

  project     = "project-name"
  environment = "production"

  requester_region              = "eu-central-1"
  requester_vpc_id              = "module.vpc-eu.id"
  requester_cidr_block          = "10.1.0.0/16"
  requester_nat_route_table_ids = [
    "rtb-123..",
    "rtb-456..",
  ]

  accepter_region              = "us-east-1"
  accepter_vpc_id              = "module.vpc-us.id"
  accepter_cidr_block          = "10.2.0.0/16"
  accepter_nat_route_table_ids = [
    "rtb-987..",
    "rtb-654..",
  ]
}
```
