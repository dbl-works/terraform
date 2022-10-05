resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  for_each            = { for metric in var.autoscale_metrics : metric.metric_name => metric }
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleUpAlarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/ECS"
  period              = var.alarm_period
  statistic           = each.value.statistic
  threshold           = each.value.threshold_up
  datapoints_to_alarm = var.datapoints_to_alarm_up

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_description = "Monitors when the ECS ${each.key} hits the threshold to scale up"
  alarm_actions = compact([
    aws_appautoscaling_policy.scale_up_ecs.arn,
    var.sns_topic_arn
  ])
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  for_each            = { for metric in var.autoscale_metrics : metric.metric_name => metric }
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleDown-${each.key}"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = each.value.metric_name
  namespace           = "AWS/ECS"
  period              = var.alarm_period
  statistic           = each.value.statistic
  threshold           = each.value.threshold_down
  evaluation_periods  = var.alarm_evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm_down

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_description = "Monitors when the ECS ${each.key} hits the threshold to scale up"
  alarm_actions = compact([
    aws_appautoscaling_policy.scale_down_ecs.arn,
    var.sns_topic_arn
  ])
}
