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

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "public_network_access_enabled" {
  type    = bool
  default = false

  nullable = false
}

variable "target_resource_ids_for_logging" {
  type    = list(string)
  default = []
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

variable "monitor_diagnostic_setting_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

# Logging
# The Free SKU has a default daily_quota_gb value of 0.5 (GB).
variable "logging_sku" {
  type = string
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.logging_sku)
    error_message = "Must be either Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018"
  }
  default = "PerGB2018"
}

variable "blob_storage_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-monitoring'."
}

# =================== Enable Private Link ===================== #
variable "privatelink_config" {
  type = object({
    subnet_id          = string
    virtual_network_id = string
  })
  default = null
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_tags = coalesce(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}
