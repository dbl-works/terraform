resource "fivetran_connector" "lambda" {
  group_id          = var.fivetran_group_id
  service           = "aws_lambda"
  sync_frequency    = 5 // min
  paused            = false
  pause_after_trial = false
  run_setup_tests   = true

  destination_schema {
    name = "cloudwatch_metrics_${var.organisation}"
  }

  config {
    function = aws_lambda_function.cloudwatch_metrics_tracker.function_name
    role_arn = aws_iam_role.lambda.arn
    region   = var.aws_region_code
  }
}
