# Terraform Module: Elasticache

A repository for setting up an elasticache cluster.



## Usage

```terraform
module "elasticache" {
  source = "github.com/dbl-works/terraform//elasticache?ref=v2021.08.24"

  project            = local.project
  environment        = local.environment
  vpc_id             = module.vpc.id
  vpc_cidr           = local.cidr_block
  subnet_ids         = module.vpc.subnet_private_ids

  # optional
  node_count = 1
  node_type  = "cache.t3.micro"
  engine_version = "6.x"
  # To enable cluster mode, use a parameter group that has cluster mode enabled.
  # The default parameter groups provided by AWS end with ".cluster.on", for example default.redis6.x.cluster.on.
  parameter_group_name = "default.redis6.x"
  # Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them.
  # If the value of snapshot_retention_limit is set to zero (0), backups are turned off.
  # Please note that setting a snapshot_retention_limit is not supported on cache.t1.micro cache nodes
  snapshot_retention_limit = 0

  # Compulsory for Cluster Mode
  num_node_groups = 2
  replicas_per_node_group = 1
}
```



## Outputs

- `endpoint`
