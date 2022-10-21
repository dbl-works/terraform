# Terraform Module: Autoscaling Policy for ECS

Setup Application AutoScaling Policy for ECS.
This module should allow the ECS to autoscale based on the metric threshold value + send notification to Slack when it scale in/out.

## Usage

```terraform
module "iam_role_for_ecs_scaling" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-ecs-scaling?ref=v2022.10.04"
}

module "ecs-autoscaling-cpu" {
  source = "github.com/dbl-works/terraform//autoscaling/ecs?ref=v2022.10.04"

  # Required
  ecs_service_name = "web"
  ecs_cluster_name = "meta-loadtesting-us-east"
  autoscale_metrics = [
    {
      metric_name    = "CPUUtilization"
      statistic      = "Average"
      threshold_up   = 60
      threshold_down = 50
    },
    {
      metric_name    = "MemoryUtilization"
      statistic      = "Average"
      threshold_up   = 60 # Optional. If missing, it would not be included in the scale up alarm
      threshold_down = 50 # Optional. If missing, it would not be included in the scale down alarm
    },
    {
      metric_name  = "TargetResponseTime"
      statistic    = "p95"
      threshold_up = 0.130 # in seconds.
      namespace    = "AWS/ApplicationELB" # Optional value, default value is AWS/ECS
      dimensions = {
        LoadBalancer = "app/fb-loadtesting/123456789"
      } # Optional value, default value is ClusterName/ServiceName
    },
  ]

  # Optional
  ecs_max_count                 = 4
  ecs_min_count                 = 1
  alarm_evaluation_periods      = 5
  datapoints_to_alarm_up        = 3
  datapoints_to_alarm_down      = 3
  alarm_period                  = 60  # seconds
  cooldown                      = 300 # Autoscale will wait for another 300s before spinning more task (if the threshold still exceed the value)
  scale_up_adjustment           = 1
  scale_up_lower_bound          = 0
  scale_down_adjustment         = -1
  scale_down_upper_bound        = 0
  sns_topic_arn                 = "arn:aws:sns:us-east-1:12345678:slack-sns" # If present, it will send notifications to the SNS topics when the alarm is triggered
  ecs_autoscale_role_arn        = module.iam_role_for_ecs_scaling.ecs_autoscale_role_arn
  scale_down_treat_missing_data = "breaching"
  scale_up_treat_missing_data   = "missing"
}

## Variables
### Required Variables
| Variables                | Descriptions                                               |
|--------------------------|------------------------------------------------------------|
| ecs_service_name         | ECS Service name                                           |
| ecs_cluster_name         | ECS Cluster name                                           |
| metric_name              | Metric which used to decide whether or not to scale in/out |
| ecs_autoscale_role_arn   | Role which allow the autoscaling policy to autoscale and read cloudwatch alarm. |
| autoscale_metrics        | {<br>&nbsp; metric_name    = string # Metric which used to decide whether or not to scale in/out <br>&nbsp; statistic      = string # The statistic to apply to the alarm's associated metric. Supported Argument: SampleCount, Average, Sum, Minimum, Maximum <br>&nbsp; threshold_up   = number # Threshold of which ECS should start to scale up <br>&nbsp; threshold_down = number # Threshold of which ECS should start to scale down <br> } |


### Optional Variables
| Variables                | Descriptions                                                                                                                                                                                        | Default Value |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| ecs_max_count            | Max capacity of the scalable target                                                                                                                                                                 | 30            |
| ecs_min_count            | Min capacity of the scalable target                                                                                                                                                                 | 1             |
| cooldown                 | Amount of time, in seconds, after a scaling activity completes before another scaling activity can start                                                                                            | 300           |
| alarm_evaluation_periods | The number of periods over which data is compared to the specified threshold.                                                                                                                       | 5             |
| alarm_period             | The period in seconds over which the specified statistic is applied.                                                                                                                                | 60            |
| datapoints_to_alarm_up   | The number of alarm data points that must breach the threshold during the evaluation period for the ecs to scale up                                                                                 | 3             |
| datapoints_to_alarm_down | The number of alarm data points that must breach the threshold during the evaluation period for the ecs to scale down                                                                               | 3             |
| scale_up_adjustment      | Number of members by which to scale, when the adjustment bounds are breached. Should be a positive number.                                                                                          | 1             |
| scale_up_lower_bound     | Lower bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as negative infinity.                                              | 0             |
| scale_down_adjustment    | Number of members by which to scale, when the adjustment bounds are breached. Should be a negative number.                                                                                          | -1            |
| scale_down_upper_bound   | Upper bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as infinity. The upper bound must be greater than the lower bound. | 0             |
| sns_topic_arn            | SNS Topics that will receive message when the threshold is hit                                                                                                                                      | null          |
