variable "environment" {}
variable "project" {}
variable "vpc_id" {}

# A custom name overrides the default {project}-{environment} convention
variable "name" {
  type        = string
  description = "Custom name for the cluster. Must be unique per account if deploying to multiple regions."
  default     = null
}

# Regional allows clusters with the same name to be in multiple regions
variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "regional" {
  default = false
  type    = bool
}

variable "allow_internal_traffic_to_ports" {
  type    = list(string)
  default = []
}

# Private IPs are where the app containers run
variable "subnet_private_ids" { type = list(string) }

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
variable "certificate_arn" {}

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
  default = []
}

variable "grant_write_access_to_s3_arns" {
  default = []
}

variable "grant_read_access_to_sqs_arns" {
  default = []
}

variable "grant_write_access_to_sqs_arns" {
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
      dimensions     = optional(map(string), {})
    }))
  }))
  default = {}
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 90
}

variable "alb_listener_rule" {
  type = list(object({
    priority         = string
    type             = string
    target_group_arn = string
    path_pattern     = optional(list(string), [])
    host_header      = optional(list(string), [])
  }))
}
