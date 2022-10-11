module "elasticache" {
  source = "../../elasticache"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  kms_key_arn = var.kms_app_arn

  allow_from_cidr_blocks = distinct(compact(flatten([
    var.vpc_cidr_block,
    var.remote_cidr_blocks,
  ])))

  # optional
  node_type                  = var.elasticache_node_type
  node_count                 = var.elasticache_node_count == null ? (var.elasticache_automatic_failover_enabled == true ? 2 : 1) : var.elasticache_node_count
  snapshot_retention_limit   = var.elasticache_snapshot_retention_limit
  data_tiering_enabled       = var.elasticache_data_tiering_enabled
  multi_az_enabled           = var.elasticache_multi_az_enabled
  automatic_failover_enabled = var.elasticache_automatic_failover_enabled

  replicas_per_node_group = var.elasticache_replicas_per_node_group
  shard_count             = var.elasticache_shards_per_replication_group
  parameter_group_name    = var.elasticache_parameter_group_name
  cluster_mode            = var.elasticache_cluster_mode
  maxmemory_policy        = var.elasticache_maxmemory_policy == null ? (var.elasticache_cluster_mode == false ? "noeviction" : null) : var.elasticache_maxmemory_policy
}
