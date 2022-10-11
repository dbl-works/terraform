data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir == null ? "${path.module}/tracker" : var.lambda_source_dir
  output_path = var.lambda_output_path == null ? "${path.module}/dist/tracker.zip" : var.lambda_output_path
}

resource "aws_lambda_function" "cloudwatch_metrics_tracker" {
  function_name = "cloudwatch_metrics_tracker_${var.organisation}_${var.aws_region_code}"
  description   = "Collect AWS Cloudwatch Metrics"
  role          = var.lambda_role_arn == null ? aws_iam_role.lambda[0].arn : var.lambda_role_arn

  filename = data.archive_file.zip.output_path
  # Used to trigger updates
  source_code_hash = data.archive_file.zip.output_base64sha256
  handler          = "index.handler"
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
  count = var.lambda_role_arn == null ? 1 : 0
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

resource "aws_iam_role_policy_attachment" "fivetran_policy_for_lambda" {
  count      = var.lambda_role_arn == null ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
