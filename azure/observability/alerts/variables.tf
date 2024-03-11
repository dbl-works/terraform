variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_app_id" {
  type = string
}

variable "cpu_percentage_threshold" {
  type    = number
  default = 80
}

variable "current_memory_in_gb" {
  type = number
}

variable "memory_percentage_threshold" {
  type    = number
  default = 80
}

variable "slack_webhook_url" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "monitor_metric_alert_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

variable "monitor_action_group_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
