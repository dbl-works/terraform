module "elasticache" {
  source = "../../elasticache"


  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  vpc_cidr    = var.vpc_cidr_block
  # availability_zones = var.vpc_availability_zones
  kms_key_arn = module.ecs-kms-key.arn

  # optional
  node_type                = var.elasticache_node_type
  replicas_per_node_group  = var.elasticache_replicas_per_node_group
  num_node_groups          = var.elasticache_shards_per_replication_group
  snapshot_retention_limit = var.elasticache_snapshot_retention_limit
}
