resource "aws_iam_role" "main" {
  name               = "${var.project}-${var.environment}-${var.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json

  inline_policy {
    name = "lambda_policy"
    policy = (
      length(var.secrets_and_kms_arns) > 0 ?
      data.aws_iam_policy_document.main.json
      :
      data.aws_iam_policy_document.dummy.json
    )
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
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# For logging
# AWSLambdaBasicExecutionRole grants permissions to upload logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}