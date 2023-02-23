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

data "aws_iam_policy_document" "main" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]
    resources = var.secrets_and_kms_arns
  }
}

data "aws_iam_policy_document" "dummy" {
  statement {
    effect    = "Deny"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:*:secret:can-t-be-blank"]
  }
}
