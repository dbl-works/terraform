resource "aws_iam_role" "lambda" {
  count = var.lambda_role_name == null ? 1 : 0
  name  = "fivetran_lambda_${var.fivetran_group_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.fivetran_aws_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" : "${var.fivetran_group_id}"
          }
        }
      },
    ]
  })

  inline_policy {
    name = "LambdaInvokePolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "InvokePermission"
          Effect   = "Allow"
          Action   = ["lambda:InvokeFunction"]
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_iam_role" "lambda" {
  count = var.lambda_role_name == null ? 0 : 1
  name  = var.lambda_role_name
}

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  count      = local.is_role_name_exist ? length(var.policy_arns_for_lambda) : 0
  role       = var.lambda_role_name == null ? aws_iam_role.lambda[0].name : var.lambda_role_name
  policy_arn = var.policy_arns_for_lambda[count.index]
}
