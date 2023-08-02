locals {
  secret_and_kms_policy_json = length(var.secrets_and_kms_arns) > 0 ? data.aws_iam_policy_document.main.json : data.aws_iam_policy_document.dummy.json
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = concat(
    [local.secret_and_kms_policy_json],
    var.lambda_policy_json == null ? [] : [var.lambda_policy_json]
  )
}

resource "aws_iam_role" "main" {
  count              = var.role_arn ? 0 : 1
  name               = "${var.project}-${var.environment}-${var.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json

  inline_policy {
    name   = "lambda_policy"
    policy = data.aws_iam_policy_document.combined.json
  }
}

data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# accessing secrets and kms keys
data "aws_iam_policy_document" "main" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]
    resources = var.secrets_and_kms_arns
  }
}

# used if no secrets are provided since we cannot attach a blank policy
data "aws_iam_policy_document" "dummy" {
  statement {
    effect    = "Deny"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:*:secret:can-t-be-blank"]
  }
}

# For deploying into a VPC
# AWSLambdaVPCAccessExecutionRole grants permissions to manage ENIs within an Amazon VPC and write to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = var.role_arn ? var.role_arn : aws_iam_role[0].main.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# For logging
# AWSLambdaBasicExecutionRole grants permissions to upload logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = var.role_arn ? var.role_arn : aws_iam_role[0].main.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
