variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "dashboard_name" {
  type    = string
  default = null
}

variable "cluster_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "elasticache_cluster_name" {
  type = string
}

variable "metric_period" {
  type    = number
  default = 60
}

variable "alarm_period" {
  type    = number
  default = 300
}

variable "alarm_evaluation_periods" {
  type        = number
  default     = 1
  description = " The number of periods over which data is compared to the specified threshold."
}

variable "slack_channel_id" {
  type    = string
  default = null
}

variable "slack_workspace_id" {
  type    = string
  default = null
}

variable "custom_metrics" {
  type    = list(any)
  default = []
}

locals {
  name = var.dashboard_name == null ? var.dashboard_name : "${var.project}-${var.environment}-${var.region}"
}
