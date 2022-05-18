module "elasticache" {
  source = "github.com/dbl-works/terraform//elasticache?ref=${var.module_version}"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.id
  vpc_cidr           = var.cidr_block
  subnet_ids         = module.vpc.subnet_private_ids
  availability_zones = var.availability_zones

  # optional
  node_count = var.node_count
  node_type  = var.node_type
}
