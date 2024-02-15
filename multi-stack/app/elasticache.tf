module "elasticache_kms" {
  source = "../../kms-key"

  alias                   = "elasticache"
  project                 = var.project
  environment             = var.environment
  description             = "Used for elasticache"
  deletion_window_in_days = var.kms_deletion_window_in_days
  multi_region            = false
}

module "elasticache" {
  source = "../../elasticache"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  kms_key_arn = module.elasticache_kms.arn

  allow_from_cidr_blocks = distinct(compact(flatten([
    var.vpc_cidr_block,
    var.remote_cidr_blocks,
  ])))

  # optional
  name                       = var.elasticache_config.name
  major_version              = var.elasticache_config.major_version
  node_type                  = var.elasticache_config.node_type
  node_count                 = var.elasticache_config.node_count == null ? (var.elasticache_config.automatic_failover_enabled ? 2 : 1) : var.elasticache_config.node_count
  snapshot_retention_limit   = var.elasticache_config.snapshot_retention_limit
  data_tiering_enabled       = var.elasticache_config.data_tiering_enabled
  multi_az_enabled           = var.elasticache_config.multi_az_enabled
  automatic_failover_enabled = var.elasticache_config.automatic_failover_enabled

  replicas_per_node_group    = var.elasticache_config.replicas_per_node_group
  shard_count                = var.elasticache_config.shards_per_replication_group
  parameter_group_name       = var.elasticache_config.parameter_group_name
  cluster_mode               = var.elasticache_config.cluster_mode
  maxmemory_policy           = var.elasticache_config.maxmemory_policy == null ? (var.elasticache_config.cluster_mode ? "volatile-lru" : "noeviction") : var.elasticache_config.maxmemory_policy
  transit_encryption_enabled = var.elasticache_config.transit_encryption_enabled
}
