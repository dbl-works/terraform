locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.terraform.secret_string
  )
}

data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = "${var.project}/terraform/${var.environment}"
}

data "aws_secretsmanager_secret" "app" {
  name = "${var.project}/app/${var.environment}"
}
