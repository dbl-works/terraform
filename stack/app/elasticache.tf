module "elasticache" {
  source = "../../elasticache"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  vpc_cidr    = module.vpc.cidr_block

  # optional
  node_count = var.elasticache_node_count
  node_type  = var.elasticache_node_type
}
