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

variable "cluster_names" {
  type    = list(string)
  default = []
}

variable "database_identifiers" {
  type    = list(string)
  default = []
}

variable "alb_arn_suffixes" {
  type    = list(string)
  default = []
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
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "custom_metrics" {
  type    = list(any)
  default = []
}

variable "sns_topic_arns" {
  type        = list(string)
  default     = []
  description = "SNS Topics that Cloudwatch alarm will send message to when the alarm transit to ALARM or OK state"
}

# https://aws.amazon.com/rds/instance-types/
variable "db_instance_class_memory_in_gb" {
  type = number
}

variable "db_is_read_replica" {
  type    = bool
  default = false
}

variable "db_allocated_storage_in_gb" {
  type = number
}


variable "datapoints_to_alarm" {
  type        = number
  default     = 1
  description = "The number of datapoints that must be breaching to trigger the alarm."
}


variable "treat_missing_data" {
  type        = string
  default     = "notBreaching"
}

locals {
  name                              = var.dashboard_name == null ? "${var.project}-${var.environment}-${var.region}" : var.dashboard_name
  db_instance_class_memory_in_bytes = var.db_instance_class_memory_in_gb * 1024 * 1024 * 1024
  db_allocated_storage_in_bytes     = var.db_allocated_storage_in_gb * 1024 * 1024 * 1024
}
