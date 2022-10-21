module "ecs-autoscaling" {
  for_each = var.autoscale_metrics_map
  source   = "../autoscaling/ecs"

  # Required
  autoscale_metrics = each.value.metrics
  ecs_cluster_name  = local.name
  ecs_service_name  = each.key
  ecs_max_count     = each.value.ecs_max_count

  # Optional
  ecs_min_count                 = each.value.ecs_min_count
  alarm_evaluation_periods      = lookup(var.autoscale_params, "alarm_evaluation_periods", 5)
  alarm_period                  = lookup(var.autoscale_params, "alarm_period", 60)
  cooldown                      = lookup(var.autoscale_params, "cooldown", 300)
  datapoints_to_alarm_down      = lookup(var.autoscale_params, "datapoints_to_alarm_down", 3)
  datapoints_to_alarm_up        = lookup(var.autoscale_params, "datapoints_to_alarm_up", 3)
  ecs_autoscale_role_arn        = lookup(var.autoscale_params, "ecs_autoscale_role_arn", null)
  scale_down_adjustment         = lookup(var.autoscale_params, "scale_down_adjustment", -1)
  scale_down_upper_bound        = lookup(var.autoscale_params, "scale_down_upper_bound", 0)
  scale_up_adjustment           = lookup(var.autoscale_params, "scale_up_adjustment", 1)
  scale_up_lower_bound          = lookup(var.autoscale_params, "scale_up_lower_bound", 0)
  sns_topic_arn                 = lookup(var.autoscale_params, "sns_topic_arn", null)
  scale_down_treat_missing_data = var.autoscaling_scale_down_treat_missing_data
  scale_up_treat_missing_data   = var.autoscaling_scale_up_treat_missing_data
}
