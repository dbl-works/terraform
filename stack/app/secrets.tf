locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.infra.secret_string
  )
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = "${var.project}/infra/${var.environment}"
}

data "aws_secretsmanager_secret" "app" {
  name = "${var.project}/app/${var.environment}"
}
