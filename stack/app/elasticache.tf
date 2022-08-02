module "elasticache" {
  source = "../../elasticache"


  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  vpc_cidr    = var.vpc_cidr_block
  kms_key_arn = var.kms_app_arn

  # optional
  node_type                = var.elasticache_node_type
  snapshot_retention_limit = var.elasticache_snapshot_retention_limit
  data_tiering_enabled     = var.elasticache_data_tiering_enabled

  replicas_per_node_group = var.elasticache_replicas_per_node_group
  shard_count             = var.elasticache_shards_per_replication_group
  parameter_group_name    = var.elasticache_parameter_group_name
  cluster_mode            = true
}
