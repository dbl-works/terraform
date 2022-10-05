module "ecs-autoscaling" {
  count  = length(var.autoscale_metrics) > 0 ? 1 : 0
  source = "../autoscaling/ecs"

  # Required
  autoscale_metrics = var.autoscale_metrics
  ecs_cluster_name  = local.name
  ecs_service_name  = lookup(var.autoscale_params, "service_name", "web")
  ecs_max_count     = lookup(var.autoscale_params, "ecs_max_count", 2)

  # Optional
  ecs_min_count            = lookup(var.autoscale_params, "ecs_min_count", 1)
  cooldown                 = lookup(var.autoscale_params, "cooldown", 300)
  alarm_evaluation_periods = lookup(var.autoscale_params, "alarm_evaluation_periods", 5)
  datapoints_to_alarm_up   = lookup(var.autoscale_params, "datapoints_to_alarm_up", 3)
  datapoints_to_alarm_down = lookup(var.autoscale_params, "datapoints_to_alarm_down", 3)
  alarm_period             = lookup(var.autoscale_params, "alarm_period", 60)
  scale_up_adjustment      = lookup(var.autoscale_params, "scale_up_adjustment", 1)
  scale_up_lower_bound     = lookup(var.autoscale_params, "scale_up_lower_bound", 0)
  scale_down_adjustment    = lookup(var.autoscale_params, "scale_down_adjustment", -1)
  scale_down_upper_bound   = lookup(var.autoscale_params, "scale_down_upper_bound", 0)
  sns_topic_arn            = lookup(var.autoscale_params, "sns_topic_arn", null)
  ecs_autoscale_role_arn   = lookup(var.autoscale_params, "ecs_autoscale_role_arn", null)
}
