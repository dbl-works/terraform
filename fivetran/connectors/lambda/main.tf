data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir == null ? "${path.module}/tracker" : var.lambda_source_dir
  output_path = var.lambda_output_path == null ? "${path.module}/dist/tracker.zip" : var.lambda_output_path
}

resource "aws_lambda_function" "cloudwatch_metrics_tracker" {
  function_name = local.function_name
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
    variables = var.script_env
  }
}
