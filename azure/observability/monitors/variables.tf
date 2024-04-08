variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

variable "container_app_environment_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "logs_retention_in_days" {
  type     = number
  nullable = false
  default  = 90
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "monitor_diagnostic_setting_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

variable "blob_storage_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-monitoring'."
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
