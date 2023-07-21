# Terraform Module: Elasticache

A repository for setting up an elasticache cluster.

## Usage

```terraform
module "elasticache" {
  source = "github.com/dbl-works/terraform//elasticache?ref=v2021.08.24"

  project                = local.project
  environment            = local.environment
  vpc_id                 = module.vpc.id
  allow_from_cidr_blocks = [local.cidr_block] # add more if you need access e.g. through a peering from another VPC
  vpc_cidr               = local.cidr_block # deprecated in favor of `vpc_cidr_blocks`
  subnet_ids             = module.vpc.subnet_private_ids
  kms_key_arn            = var.kms_key_arn # "kms_app_arn" if you use the "stack" module, i.e. the key used for the application

  # required only for non cluster mode
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  node_count = 1

  # optional
  name                       = null # pass e.g. "sidekiq" to append this to all names when you launch a 2nd Redis cluster for Sidekiq (see below)
  node_type                  = "cache.t3.micro"
  major_version              = 7
  cluster_mode               = true
  transit_encryption_enabled = true # changing this requires re-creation of the cluster
  data_tiering_enabled       = false # only available for "r6gd" node types (see warning below)
  multi_az_enabled           = true # requires at least 1 replica
  maxmemory_policy           = "noeviction" # Allowed values: volatile-lru,allkeys-lru,volatile-lfu,allkeys-lfu,volatile-random,allkeys-random,volatile-ttl,noeviction

  # To enable cluster mode, use a parameter group that has cluster mode enabled.
  # The default parameter groups provided by AWS end with ".cluster.on", for example default.redis6.x.cluster.on.
  parameter_group_name = null # e.g. "default.redis7.x", if omitted (default), a custom parameter group will be created by this module. Must be omitted for `maxmemory_policy` to be effective.

  # Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them.
  # If the value of snapshot_retention_limit is set to zero (0), backups are turned off.
  # Please note that setting a snapshot_retention_limit is not supported on cache.t1.micro cache nodes
  snapshot_retention_limit = 0

  # Compulsory for Cluster Mode
  shard_count = 2
  replicas_per_node_group = 1 # if set to 0, must disable multi-AZ
}
```

Sidekiq does not work with cluster mode. The recommended setup is to have:

* one Redis cluster (cluster-mode on) for caching
* one Redis cluster (cluster-mode off) for Sidekiq

:warning: If the node type is from the `r6gd` family, be aware that availability is limited to the following regions:

* us-east-2, us-east-1
* us-west-2, us-west-1, eu-west-1
* eu-central-1
* ap-northeast-1
* ap-southeast-1, ap-southeast-2
* ap-south-1
* ca-central-1
* sa-east-1

As of July 2022. Also, you **must** use Reds `6.2` or later.

## Outputs

* `endpoint`
