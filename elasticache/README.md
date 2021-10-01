# Terraform Module: Elasticache

A reopsitory for setting up an elasticache cluster.


## Usage

```terraform
module "elasticache" {
  source = "github.com/dbl-works/terraform//elasticache?ref=v2021.08.24"

  project            = local.project
  environment        = local.environment
  vpc_id             = module.vpc.id
  vpc_cidr           = local.cidr_block
  subnet_ids         = module.vpc.subnet_private_ids
  availability_zones = local.availability_zones

  # optional
  node_count = 1
  node_type  = "cache.t3.micro"
}
```


## Outputs
- `endpoint`
