locals {
  name = "${var.project}-rotate-circleci"
}

data "aws_secretsmanager_secret" "infra" {
  name = "${var.project}/infra/${var.environment}"
}

data "aws_kms_key" "infra" {
  key_id = "alias/${var.project}/${var.environment}/infra"
}

module "lambda" {
  source = "../lambda"

  # Required
  environment   = var.environment
  project       = var.project
  source_dir    = "${path.module}/src"
  function_name = local.name
  runtime       = "ruby3.2"
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Optional
  handler = "main.handler"

  secrets_and_kms_arns = [
    data.aws_secretsmanager_secret.app.arn,
    data.aws_kms_key.infra.arn
  ]

  environment_variables = {
    CIRCLECI_CONTEXT_NAME = var.context_name == null ? "${var.project}-aws" : var.context_name
    CIRCLECI_ORG_ID       = var.circle_ci_organization_id

    AWS_USER_NAME = var.user_name
    AWS_SECRET_ID = module.secrets.id
  }

  lambda_policy_json = data.aws_iam_policy_document.iam.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "iam" {
  statement {
    effect = "Allow"
    actions = [
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_name}"
    ]
  }
}
