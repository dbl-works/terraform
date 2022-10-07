locals {
  function_name = replace(join("_", compact([var.service_name, var.project, var.environment, var.aws_region_code])), "/-/", "_")
}

resource "fivetran_connector" "lambda" {
  group_id          = var.fivetran_group_id
  service           = "aws_lambda"
  sync_frequency    = 60 // min
  paused            = false
  pause_after_trial = false
  run_setup_tests   = true

  destination_schema {
    name = try(var.connector_name, local.function_name)
  }

  config {
    function = aws_lambda_function.cloudwatch_metrics_tracker.function_name
    role_arn = var.lambda_role_arn
    region   = var.aws_region_code
  }
}
