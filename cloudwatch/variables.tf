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

variable "elasticache_cluster_names" {
  type    = list(string)
  default = []
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

variable "custom_metrics" {
  type    = list(any)
  default = []
}

variable "sns_topic_arns" {
  type    = list(string)
  default = []
}

locals {
  name = var.dashboard_name == null ? "${var.project}-${var.environment}-${var.region}" : var.dashboard_name
}
