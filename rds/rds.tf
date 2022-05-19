resource "aws_db_instance" "main" {
  db_subnet_group_name                = aws_db_subnet_group.main.name
  allocated_storage                   = var.allocated_storage
  storage_type                        = "gp2"
  engine                              = "postgres"
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  identifier                          = "${var.project}-${var.environment}"
  db_name                             = "${var.project}_${var.environment}" # name of the initial database
  skip_final_snapshot                 = true
  username                            = var.username
  password                            = var.password
  iam_database_authentication_enabled = true
  parameter_group_name                = aws_db_parameter_group.postgres13.name
  apply_immediately                   = true
  multi_az                            = var.multi_az
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = true
  vpc_security_group_ids = [
    aws_security_group.db.id,
  ]
  backup_retention_period         = 7
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.rds-enhanced-monitoring.arn
  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade",
  ]

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }

  # Ignore certain variables, that are OK to change, or will automatically change due to their nature
  lifecycle {
    ignore_changes = [
      engine_version, # AWS will auto-update minor version changes
      latest_restorable_time,
      db_name, # if you didn't use this before it would re-create your RDS instance
    ]
  }
}
