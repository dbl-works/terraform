module "aurora-kms-key" {
  source = "../../kms-key"
  count  = var.skip_aurora ? 0 : 1

  # Required
  environment = var.environment
  project     = var.project
  alias       = "aurora"
  description = "KMS key for ${var.project}-${var.environment} RDS Aurora."

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
  multi_region            = var.rds_multi_region_kms_key
}

module "aurora" {
  source = "../../aurora"
  count  = var.skip_aurora ? 0 : 1

  depends_on = [
    module.ecs
  ]

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.subnet_private_ids
  kms_key_arn = module.aurora-kms-key[0].arn
  password    = local.credentials.db_root_password

  allow_from_cidr_blocks = module.ecs.ecs_security_group_cidr_blocks
  allow_from_security_groups = [
    module.ecs.ecs_security_group_id
  ]

  # optional
  instance_count = var.aurora_instance_count
  instance_class = var.aurora_instance_class
}
