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
  type = string
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

variable "period" {
  type    = number
  default = 60
}

variable "alarm_period" {
  type    = number
  default = 300
}

variable "alarm_evaluation_periods" {
  type    = number
  default = 1
}

variable "slack_channel_id" {
  type = string
}


variable "slack_workspace_id" {
  type = string
}

locals {
  name = "${var.dashboard_name}-${var.region}"
}
