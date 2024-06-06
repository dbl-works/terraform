resource "aws_db_parameter_group" "current" {
  count = var.parameter_group_name == null ? 1 : 0

  name   = "${local.name}-postgres${local.major_engine_version}"
  family = "postgres${local.major_engine_version}"

  parameter {
    name  = "log_statement"
    value = "none" # Logs nothing
  }

  parameter {
    name  = "log_min_duration_statement"
    value = var.log_min_duration_statement
  }

  parameter {
    name  = "rds.log_retention_period"
    value = var.log_retention_period
  }

  parameter {
    name  = "log_min_error_statement"
    value = var.log_min_error_statement
  }

  parameter {
    name  = "rds.force_ssl"
    value = 1
    # https://stackoverflow.com/questions/71640985/why-does-terraform-keeps-updating-parameter-group-of-rds-cluster
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "rds.logical_replication"
    value        = var.enable_replication ? 1 : 0
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "wal_sender_timeout"
    value        = var.enable_replication ? 0 : 60000 # default, 1 min
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "wal_buffers"
    value        = -1
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }
}
