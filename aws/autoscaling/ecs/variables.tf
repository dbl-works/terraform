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

# if we measure the response time, and we have *zero* requests, we have not enough data
# so scale down is never triggered when there are no request
variable "scale_down_treat_missing_data" {
  type        = string
  default     = "breaching"
  description = "(Optional) Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to breaching."
}

variable "scale_up_treat_missing_data" {
  type        = string
  default     = "missing"
  description = "(Optional) Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing."
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topics that will receive message when the threshold is hit"
  default     = null
}

variable "ecs_autoscale_role_arn" {
  type        = string
  description = "Role which allow the autoscaling policy to autoscale and read cloudwatch alarm."
}

variable "autoscale_metrics" {
  type = set(object({
    metric_name    = string                 # Metric which used to decide whether or not to scale in/out
    statistic      = string                 # The statistic to apply to the alarm's associated metric. Supported Argument: SampleCount, Average, Sum, Minimum, Maximum
    threshold_up   = optional(number, null) # Threshold of which ECS should start to scale up. If null, would not be included in the scale up alarm
    threshold_down = optional(number, null) # Threshold of which ECS should start to scale down. If null, would not be included in the scale down alarm
    namespace      = optional(string, "AWS/ECS")
    dimensions     = optional(map(string), null)
  }))
  default = []
}
