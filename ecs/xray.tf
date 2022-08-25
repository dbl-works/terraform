resource "aws_xray_group" "ecs_filter" {
  count      = var.enable_xray ? 1 : 0
  group_name = local.name
  # Return traces for requests that hit the ecs on the service map
  # Check filter here
  # https://docs.aws.amazon.com/xray/latest/devguide/xray-console-filters.html
  # '/livez', '/readyz', '/checks/ip', '/healthz', '/'
  filter_expression = "service(${local.name}) AND !service('in.logtail.com')"

  insights_configuration {
    insights_enabled = true
    # TODO: Setup event bridge and trigger slack
    notifications_enabled = true
  }
}

