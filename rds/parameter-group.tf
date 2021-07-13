resource "aws_db_parameter_group" "postgres13" {
  name   = "${var.project}-${var.environment}-postgres13"
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
}
