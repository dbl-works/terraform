module "rds-kms-key" {
  source = "../../kms-key"

  # Required
  environment = var.environment
  project     = var.project
  alias       = "rds"
  description = "KMS key for ${var.project}-${var.environment} RDS."

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
  multi_region            = var.rds_config.multi_region_kms_key
}

module "rds" {
  source = "../../rds"

  depends_on = [
    module.ecs
  ]

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.id
  password    = local.credentials.db_root_password
  kms_key_arn = module.rds-kms-key.arn
  subnet_ids  = module.vpc.subnet_private_ids

  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  username                        = local.credentials.db_username
  instance_class                  = var.rds_config.instance_class
  engine_version                  = var.rds_config.engine_version
  allocated_storage               = var.rds_config.allocated_storage
  storage_type                    = var.rds_config.storage_type
  multi_az                        = var.rds_config.multi_az == null ? var.environment == "production" : var.rds_config.multi_az
  master_db_instance_arn          = null
  is_read_replica                 = false
  regional                        = true
  region                          = var.region
  name                            = var.rds_config.name
  identifier                      = var.rds_config.identifier
  allow_from_cidr_blocks          = var.rds_config.allow_from_cidr_blocks
  subnet_group_name               = var.rds_config.subnet_group_name
  delete_automated_backups        = var.rds_config.delete_automated_backups
  skip_final_snapshot             = var.rds_config.skip_final_snapshot
  final_snapshot_identifier       = var.rds_config.final_snapshot_identifier
  log_min_duration_statement      = var.rds_config.log_min_duration_statement
  log_retention_period            = var.rds_config.log_retention_period
  log_min_error_statement         = var.rds_config.log_min_error_statement
  ca_cert_identifier              = var.rds_config.ca_cert_identifier
  storage_autoscaling_upper_limit = var.rds_config.storage_autoscaling_upper_limit
  backup_retention_period         = var.rds_config.backup_retention_period
}
