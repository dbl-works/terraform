data "aws_secretsmanager_secret" "app" {
  name = var.secret_name == null ? "${var.project}/app/${var.environment}" : var.secret_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  secrets = [
    for secret_name in var.secrets : {
      name : secret_name,
      valueFrom : "${data.aws_secretsmanager_secret.app.arn}:${secret_name}::"
    }
  ]
  environment_variables = flatten([
    for name, value in var.environment_variables : { name : name, value : value }
  ])
  image_name                = var.image_name == null ? "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecr_repo_name}" : var.image_name
  cloudwatch_log_group_name = "/ecs/${var.project}-${var.environment}/task"
}
