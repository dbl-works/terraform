resource "fivetran_connector" "lambda" {
  group_id        = var.fivetran_group_id
  service         = "aws_lambda"
  run_setup_tests = true

  destination_schema {
    name = var.connector_name == null ? local.function_name : var.connector_name
  }

  config {
    function = aws_lambda_function.main.function_name
    role_arn = var.lambda_role_arn
    region   = var.aws_region_code
  }
}


resource "fivetran_connector_schedule" "lambda" {
  connector_id = fivetran_connector.lambda.id

  sync_frequency    = var.sync_frequency
  paused            = false
  pause_after_trial = false
  schedule_type     = "auto"
}
