resource "aws_xray_group" "ecs_filter" {
  count      = var.enable_xray ? 1 : 0
  group_name = local.name
  # How to configure filter:https://docs.aws.amazon.com/xray/latest/devguide/xray-console-filters.html
  # Return traces for requests that hit the ecs on the service map
  filter_expression = "service(\"${local.name}\")"

  insights_configuration {
    insights_enabled = true
    # TODO: Setup event bridge and trigger slack
    notifications_enabled = true
  }
}

resource "aws_xray_group" "ecs_error" {
  count             = var.enable_xray ? 1 : 0
  group_name        = "${substr(var.project, 0, 2)}-${var.environment}-error"
  filter_expression = "service(\"${local.name}\") { error = true OR fault = true }"

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}

resource "aws_xray_group" "slow_request" {
  count             = var.enable_xray ? 1 : 0
  group_name        = "${substr(var.project, 0, 2)}-${var.environment}-slow"
  filter_expression = "service(\"${local.name}\") { responsetime > 0.12 } "

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}
