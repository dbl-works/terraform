locals {
  major_engine_version      = split(".", var.engine_version)[0]
  final_snapshot_identifier = "final-snapshot-${var.project}-${var.environment}"
  cluster_name              = "${var.project}-${var.environment}-cluster"
  name                      = var.name != null ? var.name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
  effective_instances = var.instances != null ? var.instances : [
    for _ in range(var.instance_count) : {
      instance_class = var.instance_class
      promotion_tier = 0
    }
  ]
  has_serverless_instance = anytrue([
    for inst in local.effective_instances : inst.instance_class == "db.serverless"
  ])
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier              = var.identifier == null ? local.cluster_name : var.identifier
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  database_name                   = replace("${var.project}_${var.environment}", "/[^0-9A-Za-z_]/", "_")
  master_username                 = var.username
  master_password                 = var.password
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.db.id,
  ]

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  storage_type                 = var.storage_type
  storage_encrypted            = true
  kms_key_id                   = var.kms_key_arn
  deletion_protection          = true
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.final_snapshot_identifier == null ? local.final_snapshot_identifier : var.final_snapshot_identifier
  apply_immediately            = true
  snapshot_identifier          = var.snapshot_identifier
  delete_automated_backups     = var.delete_automated_backups

  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  iam_database_authentication_enabled = true

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.has_serverless_instance ? [1] : []

    content {
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
      # Only set seconds_until_auto_pause when explicitly configured.
      # Auto-pause is only applicable when min_capacity = 0.
      # AWS returns 0 in state when auto-pause is not applicable,
      # which causes perpetual drift if a non-null default is used.
      seconds_until_auto_pause = var.seconds_until_auto_pause
    }
  }

  tags = {
    Name        = local.cluster_name
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      engine_version, # AWS will auto-update minor version changes
      database_name,  # Consistent with RDS module's db_name
      master_username,
      master_password,
      snapshot_identifier,
      # Set by AWS when this cluster joins or is promoted into an Aurora Global Database
      # (aws_rds_global_cluster with source_db_cluster_identifier). Without this, every later
      # apply would try to detach the cluster from the global database.
      global_cluster_identifier,
    ]
  }
}

# Aurora PostgreSQL Cluster Instances with updated naming
resource "aws_rds_cluster_instance" "cluster_instances" {
  count = length(local.effective_instances)

  identifier              = "${var.project}-${var.environment}-node-${count.index}"
  cluster_identifier      = aws_rds_cluster.main.cluster_identifier
  instance_class          = local.effective_instances[count.index].instance_class
  promotion_tier          = local.effective_instances[count.index].promotion_tier
  engine                  = aws_rds_cluster.main.engine
  engine_version          = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.instance.name

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.rds-enhanced-monitoring.arn
  apply_immediately               = true

  ca_cert_identifier = var.ca_cert_identifier

  tags = {
    Name        = "${var.project}-${var.environment}-node-${count.index}"
    Project     = var.project
    Environment = var.environment
  }
}
