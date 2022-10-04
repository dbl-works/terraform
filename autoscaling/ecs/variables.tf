variable "ecs_service_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "metric_name" {
  type = string
}

variable "ecs_max_count" {
  type = number
}

variable "ecs_min_count" {
  type    = number
  default = 1
}

variable "threshold_up" {
  type    = number
  default = 80
}

variable "threshold_down" {
  type    = number
  default = 20
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

variable "statistic" {
  type    = string
  default = "Average"
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
  type    = number
  default = 0
}

variable "scale_down_adjustment" {
  type        = number
  description = "Number of members by which to scale, when the adjustment bounds are breached. Should be a negative number."
  default     = -1
}

variable "scale_down_upper_bound" {
  type    = number
  default = 0
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topics that will receive message when the threshold is hit"
}

variable "ecs_autoscale_role_arn" {
  type        = string
  description = "Optional. Role for ECS to autoscale and read cloudwatch alarm. If it is not provided, it will be created in this module."
  default     = null
}
