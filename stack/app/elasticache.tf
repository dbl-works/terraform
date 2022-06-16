module "elasticache" {
  source = "../../elasticache"


  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  subnet_ids         = module.vpc.subnet_private_ids
  vpc_cidr           = var.vpc_cidr_block
  availability_zones = var.vpc_availability_zones
  kms_key_arn        = module.ecs-kms-key.arn

  # optional
  node_count = var.elasticache_node_count
  node_type  = var.elasticache_node_type
}
