# Terraform Module: ECS Cluster

Create a compute cluster for hosting docker based apps.


## Usage

```
module "ecs" {
  source "github.com/dbl-works/terraform//ecs"

  project = local.project
  environment = local.environment
  vpc_id = module.vpc.id
  subnet_private_ids = module.vpc.subnet_private_ids
  subnet_public_ids = module.vpc.subnet_private_ids
  secrets_arns = []
  kms_key_arns = []
}
```
