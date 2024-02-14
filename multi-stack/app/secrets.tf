locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.infra.secret_string
  )
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = "${var.project}/infra/${var.environment}"
}
