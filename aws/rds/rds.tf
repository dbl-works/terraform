locals {
  major_engine_version      = split(".", var.engine_version)[0]
  final_snapshot_identifier = "final-snapshot-${var.project}-${var.environment}"
  parameter_group_name      = var.parameter_group_name == null ? aws_db_parameter_group.current[0].name : var.parameter_group_name
}

resource "aws_db_instance" "main" {
  allow_major_version_upgrade         = true
  db_subnet_group_name                = aws_db_subnet_group.main.name
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  engine                              = var.is_read_replica ? null : "postgres"
  engine_version                      = var.is_read_replica ? null : local.major_engine_version # Use major version only to allow AWS to update the minor/patch version automatically
  instance_class                      = var.instance_class
  identifier                          = var.identifier == null ? "${var.project}-${var.environment}${var.is_read_replica ? "-read-replica" : ""}" : var.identifier
  db_name                             = var.is_read_replica ? null : replace("${var.project}_${var.environment}", "/[^0-9A-Za-z_]/", "_") # name of the initial database
  username                            = var.is_read_replica ? null : var.username                                                         # credentials of the master DB are used
  password                            = var.is_read_replica ? null : var.password                                                         # credentials of the master DB are used
  iam_database_authentication_enabled = true
  parameter_group_name                = local.parameter_group_name
  apply_immediately                   = true
  multi_az                            = var.multi_az
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = true
  vpc_security_group_ids = [
    aws_security_group.db.id,
  ]
  backup_retention_period         = var.is_read_replica ? 0 : var.backup_retention_period
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.rds-enhanced-monitoring.arn
  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  snapshot_identifier             = var.snapshot_identifier
  delete_automated_backups        = var.delete_automated_backups
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.is_read_replica ? null : (var.final_snapshot_identifier == null ? local.final_snapshot_identifier : var.final_snapshot_identifier)
  ca_cert_identifier              = var.ca_cert_identifier
  max_allocated_storage           = var.storage_autoscaling_upper_limit

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade",
  ]

  # the "identifier" may be used when the replica is in the same region as the master
  # otherwise, the ARN must be used.
  replicate_source_db = var.master_db_instance_arn

  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
  }

  # Ignore certain variables, that are OK to change, or will automatically change due to their nature
  lifecycle {
    ignore_changes = [
      engine_version, # AWS will auto-update minor version changes
      db_name,        # if you didn't use this before it would re-create your RDS instance
      snapshot_identifier,
      username,
      password,
    ]
  }
}
