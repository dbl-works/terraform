locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.rds.secret_string
  )
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = var.rds_secret_manager_id
}

data "aws_secretsmanager_secret_version" "app" {
  for_each = var.project_settings

  secret_id = "${each.key}/app/${var.environment}"
}
