variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

# A custom name overrides the default {project}-{environment} convention
variable "name" {
  type        = string
  description = "Custom name for the cluster. Must be unique per account if deploying to multiple regions."
  default     = null
}

variable "regional" {
  default = false
  type    = bool
}

variable "keep_alive_timeout" {
  type    = number
  default = 60
  validation {
    condition     = var.keep_alive_timeout >= 60 && var.keep_alive_timeout <= 4000
    error_message = "keep_alive_timeout must be between 60 and 4000"
  }
}

variable "allow_internal_traffic_to_ports" {
  type    = list(string)
  default = []
}

variable "allow_alb_traffic_to_ports" {
  type    = list(string)
  default = []
}

# Public subnets are where forwarders run, such as a bastion, NAT or proxy
variable "subnet_public_ids" { type = list(string) }

# Allow containers to access the following resources from inside the cluster
variable "secrets_arns" {
  type    = list(string)
  default = []
}
variable "kms_key_arns" {
  type    = list(string)
  default = []
}

# Sets the certficate for https traffic into the cluster
# If not passed, no SSL endpoint will be setup
variable "certificate_arn" {
  type = string
}

variable "additional_certificate_arns" {
  description = "Additional certificates to add to the load balancer"
  default     = []

  type = list(object({
    name = string
    arn  = string
  }))
}

# CIDR blocks to allow traffic from
# Setting this will enable NLB traffic
variable "allowlisted_ssh_ips" {
  type    = list(string)
  default = []
}

# This is where the load balancer will send health check requests to the app containers
variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "grant_read_access_to_s3_arns" {
  type    = list(string)
  default = []
}

variable "grant_write_access_to_s3_arns" {
  default = []
  type    = list(string)
}

variable "grant_read_access_to_sqs_arns" {
  type    = list(string)
  default = []
}

variable "grant_write_access_to_sqs_arns" {
  type    = list(string)
  default = []
}

variable "custom_policies" {
  default = []
}

variable "enable_dashboard" {
  type    = bool
  default = true
}

variable "enable_xray" {
  type        = bool
  default     = false
  description = "Grant Xray permission to ECS"
}

##########################################################################
# AutoScaling Configuration
##########################################################################
variable "autoscale_params" {
  type = object({
    alarm_evaluation_periods      = optional(number)
    alarm_period                  = optional(number)
    cooldown                      = optional(number)
    datapoints_to_alarm_up        = optional(number)
    datapoints_to_alarm_down      = optional(number)
    scale_up_adjustment           = optional(number)
    scale_up_lower_bound          = optional(number)
    scale_down_adjustment         = optional(number)
    scale_down_upper_bound        = optional(number)
    ecs_autoscale_role_arn        = optional(string)
    sns_topic_arn                 = optional(string)
    scale_down_treat_missing_data = optional(string, "breaching")
    scale_up_treat_missing_data   = optional(string, "missing")
  })
  default = {}
}

variable "autoscale_metrics_map" {
  type = map(object({
    ecs_min_count = optional(number)
    ecs_max_count = optional(number)
    metrics = set(object({
      metric_name    = string                 # Metric which used to decide whether or not to scale in/out
      statistic      = string                 # The statistic to apply to the alarm's associated metric. Supported Argument: SampleCount, Average, Sum, Minimum, Maximum
      threshold_up   = optional(number, null) # Threshold of which ECS should start to scale up. If null, would not be included in the scale up alarm
      threshold_down = optional(number, null) # Threshold of which ECS should start to scale down. If null, would not be included in the scale down alarm
      namespace      = optional(string, "AWS/ECS")
      dimensions     = optional(map(string), null)
    }))
  }))
  default = {}
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 90
}

variable "alb_listener_rules" {
  type = list(object({
    priority         = string
    type             = string
    target_group_arn = string
    path_pattern     = optional(list(string), [])
  }))
  default = []
}

variable "service_discovery_enabled" {
  type    = bool
  default = true
}

variable "monitored_service_groups" {
  type        = list(string)
  default     = ["service:web"]
  description = "ECS service groups to monitor STOPPED containers."
}

variable "health_check_options" {
  type = object({
    healthy_threshold   = optional(number, 2)  # The number of consecutive health checks successes required before considering an unhealthy target healthy.
    unhealthy_threshold = optional(number, 5)  # The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold.
    timeout             = optional(number, 30) # The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds.
    interval            = optional(number, 60) # The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds.
    matcher             = optional(string, "200,204")
  })
  default = {}
}

variable "enable_container_insights" {
  type    = bool
  default = true
}
