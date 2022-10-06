variable "ecs_service_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_max_count" {
  type        = number
  default     = 30
  description = "Max capacity of the scalable target"
}

variable "ecs_min_count" {
  type        = number
  default     = 1
  description = "Min capacity of the scalable target"
}

variable "cooldown" {
  type        = number
  default     = 300 # in seconds
  description = "Amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
}

variable "alarm_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 5
}

variable "alarm_period" {
  type    = number
  default = 60
}

# Say the evaluation_periods is 5, and datapoints_to_alarm_up is 3,
# When the threshold is hit during 3 out of 5 datapoints,
# the alarm will be triggered
variable "datapoints_to_alarm_up" {
  type        = number
  default     = 3
  description = "The number of alarm data points that must breach the threshold during the evaluation period for the ecs to scale up"
}

variable "datapoints_to_alarm_down" {
  type        = number
  default     = 3
  description = "The number of alarm data points that must breach the threshold during the evaluation period for the ecs to scale down"
}

variable "scale_up_adjustment" {
  type        = number
  description = "Number of members by which to scale, when the adjustment bounds are breached. Should be a positive number."
  default     = 1
}

variable "scale_up_lower_bound" {
  type        = number
  default     = 0
  description = "Lower bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as negative infinity."
}

variable "scale_down_adjustment" {
  type        = number
  description = "Number of members by which to scale, when the adjustment bounds are breached. Should be a negative number."
  default     = -1
}

variable "scale_down_upper_bound" {
  type        = number
  default     = 0
  description = "Upper bound for the difference between the alarm threshold and the CloudWatch metric. Without a value, AWS will treat this bound as infinity. The upper bound must be greater than the lower bound."
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topics that will receive message when the threshold is hit"
  default     = null
}

variable "ecs_autoscale_role_arn" {
  type        = string
  default     = null
  description = "Optional. Role which allow the autoscaling policy to autoscale and read cloudwatch alarm. If it is not provided, the role will be created in this module."
}

variable "threshold_up" {
  type        = number
  description = "Default value of threshold of which ECS should start to scale up"
  default     = 80
}

variable "threshold_down" {
  type        = number
  description = "Default value of threshold of which ECS should start to scale down"
  default     = 30
}

variable "autoscale_metrics" {
  type = set(object({
    metric_name    = string           # Metric which used to decide whether or not to scale in/out
    statistic      = string           # The statistic to apply to the alarm's associated metric. Supported Argument: SampleCount, Average, Sum, Minimum, Maximum
    threshold_up   = optional(number) # Threshold of which ECS should start to scale up
    threshold_down = optional(number) # Threshold of which ECS should start to scale down
  }))
  default = []
}
