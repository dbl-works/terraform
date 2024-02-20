resource "aws_iam_role" "lambda" {
  name = "fivetran_lambda_${var.fivetran_group_id}"

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
