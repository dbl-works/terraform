resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.ecs_max_count
  min_capacity       = var.ecs_min_count
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs" # AWS service namespace of the scalable target
  role_arn           = var.ecs_autoscale_role_arn == null ? aws_iam_role.ecs-autoscale-role[0].arn : var.ecs_autoscale_role_arn
}

resource "aws_appautoscaling_policy" "scale_up_ecs" {
  name               = "${var.ecs_cluster_name}-${var.ecs_service_name}-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity" # Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity
    cooldown                = var.cooldown       # seconds
    metric_aggregation_type = "Average"          # Valid values are "Minimum", "Maximum", and "Average".

    # Understand how step_adjustment works: https://ig.nore.me/2018/02/autoscaling-ecs-containers-using-cloudformation/
    step_adjustment {
      # When the CPU >= (threshold_up + scale_up_lower_bound),
      # Increase the task count by (scale_up_adjustment) count
      metric_interval_lower_bound = var.scale_up_lower_bound
      scaling_adjustment          = var.scale_up_adjustment # positive value = scales up; negative value = scales down
    }
  }

  depends_on = [
    aws_appautoscaling_target.ecs_target
  ]
}

resource "aws_appautoscaling_policy" "scale_down_ecs" {
  name               = "${var.ecs_cluster_name}-${var.ecs_service_name}-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity" # Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity
    cooldown                = var.cooldown       # seconds
    metric_aggregation_type = "Average"          # Valid values are "Minimum", "Maximum", and "Average".

    # Understand how step_adjustment works: https://ig.nore.me/2018/02/autoscaling-ecs-containers-using-cloudformation/
    step_adjustment {
      # When the CPU >= (threshold_down + scale_down_upper_bound),
      # Increase the task count by (scale_down_adjustment) count
      metric_interval_upper_bound = var.scale_down_upper_bound
      scaling_adjustment          = var.scale_down_adjustment # positive value = scales up; negative value = scales down
    }
  }

  depends_on = [
    aws_appautoscaling_target.ecs_target
  ]
}
