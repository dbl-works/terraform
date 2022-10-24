locals {
  scale_up_metrics = [
    for metric in var.autoscale_metrics : metric if metric.threshold_up != null
  ]
  scale_up_expression = join(" || ", [
    for metric in local.scale_up_metrics : "${lower(metric.metric_name)} > ${metric.threshold_up}"
    ]
  )

  scale_down_metrics = [
    for metric in var.autoscale_metrics : metric if metric.threshold_down != null
  ]
  scale_down_expression = join(" || ", [
    for metric in local.scale_down_metrics : "FILL(${lower(metric.metric_name)}, ${metric.threshold_down - 0.01}) < ${metric.threshold_down}"
    ]
  )

  less_than_threshold_up_expression = replace(replace(local.scale_up_expression, "||", "&&"), ">", "<")
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  count               = length(local.scale_up_metrics) > 0 ? 1 : 0
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleUpAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = 1
  datapoints_to_alarm = var.datapoints_to_alarm_up
  treat_missing_data  = var.scale_up_treat_missing_data

  metric_query {
    id          = "e1"
    expression  = "IF (${local.scale_up_expression},1,0)"
    label       = "Exceed Scale Up Threshold"
    return_data = "true"
  }

  dynamic "metric_query" {
    for_each = { for metric in local.scale_up_metrics : metric.metric_name => metric }
    content {
      id = lower(metric_query.key)

      metric {
        metric_name = metric_query.value.metric_name
        namespace   = metric_query.value.namespace
        period      = var.alarm_period
        stat        = metric_query.value.statistic

        dimensions = metric_query.value.dimensions == null ? {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_service_name
        } : metric_query.value.dimensions
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
  count               = length(local.scale_down_metrics) > 0 ? 1 : 0
  alarm_name          = "ECS-${var.ecs_cluster_name}-${var.ecs_service_name}-ScaleDownAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = 1
  datapoints_to_alarm = var.datapoints_to_alarm_down
  treat_missing_data  = var.scale_down_treat_missing_data

  metric_query {
    id = "e1"
    # Make sure all fo the expression is less than the threshold_up value
    # So we don't stop the autoscaling from spinning more resources
    expression  = "IF (((${local.scale_down_expression}) && ${local.less_than_threshold_up_expression}),1,0)"
    label       = "Exceed Scale Down Threshold"
    return_data = "true"
  }

  dynamic "metric_query" {
    # Include all metrics here so less_than_threshold_up_expression would not throw error due to missing metrics
    for_each = { for metric in var.autoscale_metrics : metric.metric_name => metric }
    content {
      id = lower(metric_query.key)

      metric {
        metric_name = metric_query.value.metric_name
        namespace   = metric_query.value.namespace
        period      = var.alarm_period
        stat        = metric_query.value.statistic

        dimensions = metric_query.value.dimensions == null ? {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_service_name
        } : metric_query.value.dimensions
      }
    }
  }


  alarm_description = "Monitors when the ECS hits the threshold to scale down"
  alarm_actions = compact([
    aws_appautoscaling_policy.scale_down_ecs.arn,
    var.sns_topic_arn
  ])
}
