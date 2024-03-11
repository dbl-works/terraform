variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

# The Free SKU has a default daily_quota_gb value of 0.5 (GB).
variable "sku" {
  type = string
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "Must be either Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018"
  }
  default = "PerGB2018"
}

variable "resource_group_name" {
  type = string
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

variable "container_app_id" {
  type = string
}

variable "logs_retention_in_days" {
  type     = number
  nullable = false
  default  = 90
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
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
