resource "aws_db_parameter_group" "postgres13" {
  name   = "${local.name}-postgres13"
  family = "postgres13"
  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }
  parameter {
    name  = "rds.force_ssl"
    value = 1
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
    value        = -1 # this should be default, but apparently its not on AWS RDS https://postgresqlco.nf/doc/en/param/wal_buffers/
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "postgres14" {
  name   = "${local.name}-postgres14"
  family = "postgres14"
  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }
  parameter {
    name  = "rds.force_ssl"
    value = 1
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
