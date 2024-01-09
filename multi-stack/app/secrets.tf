locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.rds.secret_string
  )
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = var.rds_secret_manager_id
}
