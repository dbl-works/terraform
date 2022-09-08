data "archive_file" "zip" {
  type = "zip"
  source_dir  = "${path.module}/tracker"
  output_path = "${path.module}/dist/tracker.zip"
}

resource "aws_lambda_function" "cloudwatch_metrics_tracker" {
  function_name = "cloudwatch_metrics_tracker"
  description   = "Collect AWS Cloudwatch Metrics"
  role          = aws_iam_role.lambda.arn

  filename = data.archive_file.zip.output_path
  # Used to trigger updates
  source_code_hash = data.archive_file.zip.output_base64sha256
  handler = "index.handler"
  # List of available runtimes: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "nodejs16.x"
  timeout = 300

  environment {
    variables = {
      RESOURCES_DATA = jsonencode(var.tracked_resources_data)
      PERIOD         = "3600"
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "fivetran_lambda"

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

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
