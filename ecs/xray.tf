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

# Refer to here for the sampling rules
# https://docs.aws.amazon.com/xray/latest/devguide/xray-console-sampling.html
resource "aws_xray_sampling_rule" "ecs" {
  rule_name      = "healthcheck"
  priority       = 1000
  version        = 1
  reservoir_size = 0 # request per second
  # The percentage of matching requests to instrument, after the reservoir is exhausted. The rate can be an integer or a float.
  fixed_rate  = 0
  url_path    = "/livez|/readyz|checks/ip|/healthz"
  host        = "*"
  http_method = "GET"
  # The name of the instrumented service, as it appears in the service map.
  service_name = "*"
  # X-Ray SDK – Not supported. The SDK can only use rules with Resource ARN set to *.
  resource_arn = "*"
  service_type = "AWS::ECS::Container"
}
