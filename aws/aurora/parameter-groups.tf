# Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "main" {
  name   = "${local.name}-aurora-postgres${local.major_engine_version}"
  family = "aurora-postgresql${local.major_engine_version}"

  parameter {
    name  = "log_statement"
    value = "none"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.log_min_duration_statement
  }

  parameter {
    name  = "log_min_error_statement"
    value = var.log_min_error_statement
  }

  # Only set logical replication parameters when explicitly enabled
  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    }
  }

  # Required for zero-ETL integration - only when replication is enabled
  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "aurora.enhanced_logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    }
  }

  # IMPORTANT: Explicitly disable Global Database replication features
  # These MUST be set to 0 when using logical replication for zero-ETL
  # to prevent conflicts with Global Database replication
  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "aurora.logical_replication_backup"
      value        = "0"
      apply_method = "pending-reboot"
    }
  }

  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "aurora.logical_replication_globaldb"
      value        = "0"
      apply_method = "pending-reboot"
    }
  }

  # Additional parameters required for logical replication to work properly
  # According to AWS docs, these need to be adjusted when enabling logical replication
  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "max_replication_slots"
      value        = "10"  # AWS recommends at least equal to planned publications + subscriptions
      apply_method = "pending-reboot"
    }
  }

  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "max_wal_senders"
      value        = "10"  # Should be at least equal to active replication slots
      apply_method = "pending-reboot"
    }
  }

  dynamic "parameter" {
    for_each = var.enable_replication ? [1] : []
    content {
      name         = "max_logical_replication_workers"
      value        = "4"  # Default is typically 4
      apply_method = "pending-reboot"
    }
  }

  # Note: aurora.logical_replication_backup and aurora.logical_replication_globaldb
  # should NOT be set when using logical replication for zero-ETL as they are for
  # Global Database replication and can cause conflicts.

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${local.name}-aurora-cluster"
    Project     = var.project
    Environment = var.environment
  }
}

# Aurora Instance Parameter Group
resource "aws_db_parameter_group" "instance" {
  name   = "${local.name}-aurora-instance-postgres${local.major_engine_version}"
  family = "aurora-postgresql${local.major_engine_version}"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${local.name}-aurora-instance"
    Project     = var.project
    Environment = var.environment
  }
}
