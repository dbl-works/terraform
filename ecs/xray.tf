locals {
  health_check_urls = [
    "/livez", "/readyz", "/checks/ip", "/healthz"
  ]

  health_check_expression = join(" ", [for url in local.health_check_urls : "AND !(http.url CONTAINS '${url}')"])

}

resource "aws_xray_group" "ecs_filter" {
  count      = var.enable_xray ? 1 : 0
  group_name = local.name
  # Return traces for requests that hit the ecs on the service map
  # Check filter here
  # https://docs.aws.amazon.com/xray/latest/devguide/xray-console-filters.html
  # '/livez', '/readyz', '/checks/ip', '/healthz', '/'
  filter_expression = "service(${local.name}) AND !service('in.logtail.com') ${local.health_check_expression}"

  insights_configuration {
    insights_enabled = true
    # TODO: Setup event bridge and trigger slack
    notifications_enabled = true
  }
}

resource "aws_xray_sampling_rule" "ecs" {
  rule_name      = "filter health check"
  priority       = 1000
  version        = 1
  reservoir_size = 1000
  # The percentage of matching requests to instrument, after the reservoir is exhausted. The rate can be an integer or a float.
  fixed_rate   = 0.05
  url_path     = "*"
  host         = "*"
  http_method  = "*"
  service_type = "AWS::ECS::Container"
  service_name = "*"
  # X-Ray SDK – Not supported. The SDK can only use rules with Resource ARN set to *.
  resource_arn = "*"

  attributes = {
    Hello = "Tris"
  }
}
