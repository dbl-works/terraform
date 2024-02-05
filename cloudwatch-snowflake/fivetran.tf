resource "fivetran_connector" "lambda" {
  group_id        = var.fivetran_group_id
  service         = "aws_lambda"
  run_setup_tests = true

  destination_schema {
    name = "cloudwatch_metrics_${var.organisation}_${replace(var.aws_region_code, "/-/", "_")}"
  }

  config {
    function = aws_lambda_function.cloudwatch_metrics_tracker.function_name
    role_arn = var.lambda_role_arn == null ? aws_iam_role.lambda[0].arn : var.lambda_role_arn
    region   = var.aws_region_code
  }
}

resource "fivetran_connector_schedule" "lambda" {
  connector_id = fivetran_connector.lambda.id

  sync_frequency  = "60"
  daily_sync_time = "03:00"

  paused            = false
  pause_after_trial = false

  schedule_type = "auto"
}
