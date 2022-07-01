module "rds-kms-key" {
  source = "../../kms-key"
  count  = var.rds_master_db_kms_key_arn == null ? 1 : 0

  # Required
  environment = var.environment
  project     = var.project
  alias       = "rds"
  description = "kms key for ${var.project} RDS"

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}

module "rds" {
  source = "../../rds"

  project                    = var.project
  environment                = var.environment
  account_id                 = var.account_id
  region                     = var.region
  vpc_id                     = module.vpc.id
  password                   = var.rds_is_read_replica ? null : local.credentials.db_root_password
  kms_key_arn                = var.rds_master_db_kms_key_arn == null ? module.rds-kms-key[0].arn : var.rds_master_db_kms_key_arn
  subnet_ids                 = module.vpc.subnet_private_ids
  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  username               = var.rds_is_read_replica ? null : local.credentials.db_username
  instance_class         = var.rds_instance_class
  engine_version         = var.rds_engine_version
  allocated_storage      = var.rds_allocated_storage
  multi_az               = var.environment == "production"
  master_db_instance_arn = var.rds_master_db_instance_arn
  is_read_replica        = var.rds_is_read_replica
}
