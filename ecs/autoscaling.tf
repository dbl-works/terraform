module "ecs-autoscaling" {
  for_each = { for metric in var.autoscale_metrics : "${metric.service_name}-${var.metric_name}" => metric }
  source   = "../autoscaling/ecs"

  # Required
  ecs_service_name = each.value.service_name
  ecs_cluster_name = local.name
  metric_name      = each.value.metric_name
  ecs_max_count    = var.autoscale_params.ecs_max_count

  # Optional
  ecs_min_count            = lookup(var.autoscale_params, "ecs_min_count", 1)
  statistic                = each.value.statistic
  threshold_up             = each.value.threshold_up
  threshold_down           = each.value.threshold_down
  cooldown                 = lookup(var.autoscale_params, "cooldown", 300)
  alarm_evaluation_periods = lookup(var.autoscale_params, "alarm_evaluation_periods", 5)
  alarm_period             = lookup(var.autoscale_params, "alarm_period", 60)
  datapoints_to_alarm_up   = lookup(var.autoscale_params, "datapoints_to_alarm_up", 3)
  datapoints_to_alarm_down = lookup(var.autoscale_params, "datapoints_to_alarm_down", 3)
  scale_up_adjustment      = lookup(var.autoscale_params, "scale_up_adjustment", 1)
  scale_up_lower_bound     = lookup(var.autoscale_params, "scale_up_lower_bound", 0)
  scale_down_adjustment    = lookup(var.autoscale_params, "scale_down_adjustment", -1)
  scale_down_upper_bound   = lookup(var.autoscale_params, "scale_down_upper_bound", 0)
  sns_topic_arn            = lookup(var.autoscale_params, "sns_topic_arn", null)
  ecs_autoscale_role_arn   = lookup(var.autoscale_params, "ecs_autoscale_role_arn", null)
}
