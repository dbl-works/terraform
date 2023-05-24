resource "fivetran_connector" "lambda" {
  group_id          = var.fivetran_group_id
  service           = "aws_lambda"
  sync_frequency    = var.sync_frequency // min
  paused            = false
  pause_after_trial = false
  run_setup_tests   = true

  destination_schema {
    name = var.destination_schema_name == null ? local.function_name : var.destination_schema_name
  }

  config {
    function = aws_lambda_function.main.function_name
    role_arn = var.lambda_role_arn
    region   = var.aws_region_code
  }
}
