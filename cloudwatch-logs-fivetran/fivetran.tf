resource "fivetran_connector" "lambda" {
  group_id          = var.fivetran_group_id
  service           = "aws_lambda"
  sync_frequency    = 60 // min
  paused            = false
  pause_after_trial = false
  run_setup_tests   = true

  # A destination schema defines how your data is structured in your destination.
  destination_schema {
    name = var.fivetran_connector_name
  }

  config {
    function = aws_lambda_function.cloudwatch_logs.function_name
    role_arn = var.lambda_role_arn == null ? aws_iam_role.lambda[0].arn : var.lambda_role_arn
    region   = var.aws_region_code
  }
}
