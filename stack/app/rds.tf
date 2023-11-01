module "rds-kms-key" {
  source = "../../kms-key"
  count  = (var.rds_master_db_kms_key_arn != null || var.skip_rds) ? 0 : 1

  # Required
  environment = var.environment
  project     = var.project
  alias       = "rds"
  description = "KMS key for ${var.project}-${var.environment} RDS."

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
  multi_region            = var.rds_multi_region_kms_key
}

module "rds" {
  source = "../../rds"
  count  = var.skip_rds ? 0 : 1

  depends_on = [
    module.ecs
  ]

  project     = var.project
  environment = var.environment
  account_id  = var.account_id
  region      = var.region
  vpc_id      = module.vpc.id
  password    = var.rds_is_read_replica ? null : local.credentials.db_root_password
  kms_key_arn = var.rds_master_db_kms_key_arn == null ? module.rds-kms-key[0].arn : var.rds_master_db_kms_key_arn
  subnet_ids  = module.vpc.subnet_private_ids

  allow_from_security_groups = [
    module.ecs.ecs_security_group_id,
  ]

  # optional
  username                   = var.rds_is_read_replica ? null : local.credentials.db_username
  instance_class             = var.rds_instance_class
  engine_version             = var.rds_engine_version
  allocated_storage          = var.rds_allocated_storage
  multi_az                   = var.rds_multi_az == null ? var.environment == "production" : var.rds_multi_az
  master_db_instance_arn     = var.rds_master_db_instance_arn
  is_read_replica            = var.rds_is_read_replica
  regional                   = var.regional
  name                       = var.rds_name
  identifier                 = var.rds_identifier
  allow_from_cidr_blocks     = var.rds_allow_from_cidr_blocks
  subnet_group_name          = var.rds_subnet_group_name
  delete_automated_backups   = var.rds_delete_automated_backups
  skip_final_snapshot        = var.rds_skip_final_snapshot
  final_snapshot_identifier  = var.rds_final_snapshot_identifier
  log_min_duration_statement = var.rds_log_min_duration_statement
  log_retention_period       = var.rds_log_retention_period
  log_min_error_statement    = var.rds_log_min_error_statement
  ca_cert_identifier         = var.rds_ca_cert_identifier
}
