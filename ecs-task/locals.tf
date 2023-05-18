data "aws_secretsmanager_secret" "app" {
  name = var.secrets_alias == null ? "${var.project}/app/${var.environment}" : var.secrets_alias
}

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
  secrets = [
    for secret_name in var.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]
  environment_variables = flatten([
    for name, value in var.environment_variables : { name : name, value : value }
  ])
}
