resource "aws_cloudwatch_event_rule" "hourly" {
  name        = "hourly"
  description = "Fires every hour at min 0. eg. 9.00am, 10.00am etc"
  # https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "track_cloudwatch_metrics_hourly" {
  rule      = aws_cloudwatch_event_rule.hourly.name
  target_id = "lambda"
  arn       = aws_lambda_function.cloudwatch_metrics_tracker.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_metrics_tracker.function_name
  # The principal who is getting this permission
  principal  = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.hourly.arn
}

data "archive_file" "zip" {
  type = "zip"
  # TODO
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
  # TODO:
  handler = "tracker.handler"
  # List of available runtimes: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "nodejs16.x"
}

resource "aws_iam_role" "lambda" {
  name = "lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
