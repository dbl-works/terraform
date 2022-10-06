locals {
  threshold_up          = var.threshold_up
  scale_up_expression   = join(" || ", [for metric in var.autoscale_metrics : "${lower(metric.metric_name)} > ${lookup(metric, "threshold_up", local.threshold_up)}"])
  scale_down_expression = join(" || ", [for metric in var.autoscale_metrics : "${lower(metric.metric_name)} < ${lookup(metric, "threshold_down", var.threshold_down)}"])
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  count               = length(var.autoscale_metrics) > 0 ? 1 : 0
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleUpAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = 1
  datapoints_to_alarm = var.datapoints_to_alarm_up

  metric_query {
    id          = "e1"
    expression  = "IF (${local.scale_up_expression},1,0)"
    label       = "Exceed Scale Up Threshold"
    return_data = "true"
  }

  dynamic "metric_query" {
    for_each = { for metric in var.autoscale_metrics : metric.metric_name => metric }
    content {
      id = lower(metric_query.key)

      metric {
        metric_name = metric_query.value.metric_name
        namespace   = "AWS/ECS"
        period      = var.alarm_period
        stat        = metric_query.value.statistic

        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_service_name
        }
      }
    }
  }

  alarm_description = "Monitors when the ECS hits the threshold to scale up"
  alarm_actions = compact([
    aws_appautoscaling_policy.scale_up_ecs.arn,
    var.sns_topic_arn
  ])
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  count               = length(var.autoscale_metrics) > 0 ? 1 : 0
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleDownAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = 1
  datapoints_to_alarm = var.datapoints_to_alarm_down

  metric_query {
    id          = "e1"
    expression  = "IF (${local.scale_down_expression},1,0)"
    label       = "Exceed Scale Down Threshold"
    return_data = "true"
  }

  dynamic "metric_query" {
    for_each = { for metric in var.autoscale_metrics : metric.metric_name => metric }
    content {
      id = lower(metric_query.key)

      metric {
        metric_name = metric_query.value.metric_name
        namespace   = "AWS/ECS"
        period      = var.alarm_period
        stat        = metric_query.value.statistic

        dimensions = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_service_name
        }
      }
    }
  }


  alarm_description = "Monitors when the ECS hits the threshold to scale down"
  alarm_actions = compact([
    aws_appautoscaling_policy.scale_down_ecs.arn,
    var.sns_topic_arn
  ])
}
