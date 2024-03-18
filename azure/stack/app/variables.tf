variable "resource_group_name" {
  type = string
}

variable "user_assigned_identity_name" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "blob_storage_config" {
  type = map(object({
    container_access_type           = optional(string, null)
    account_kind                    = optional(string, null)
    account_tier                    = optional(string, null)
    account_replication_type        = optional(string, null)
    public_network_access_enabled   = optional(bool, null)
    allow_nested_items_to_be_public = optional(bool, null)
    versioning_enabled              = optional(bool, null)
    static_website = optional(object({
      index_document     = string
      error_404_document = string
    }), null)
  }))
  default = {}
}

variable "container_registry_config" {
  type = object({
    name                          = optional(string, null)
    sku                           = optional(string, "Basic")
    retention_in_days             = optional(number, 14)
    public_network_access_enabled = optional(bool, false)
    admin_enabled                 = optional(bool, true)
  })
  default = {}
}

variable "database_config" {
  type = object({
    version      = optional(string, null)
    storage_mb   = optional(number, null)
    storage_tier = optional(string, null)
    sku_name     = optional(string, null)
  })
  default = {}
}

variable "administrator_login" {
  sensitive = true
  type      = string
}

variable "administrator_password" {
  sensitive = true
  type      = string
}

variable "container_app_config" {
  type = object({
    name                         = optional(string, null)
    environment_variables        = optional(map(string), {})
    secret_variables             = optional(list(string), [])
    target_port                  = optional(number, null)
    exposed_port                 = optional(number, null)
    cpu                          = optional(number, 0.25)
    memory                       = optional(string, "0.5Gi")
    image_version                = optional(string, "latest")
    log_analytics_workspace_name = optional(string, null)
    logs_retention_in_days       = optional(number, null)
    # https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
    health_check_options = optional(object({
      port                    = optional(string, null)
      transport               = optional(string, null)
      failure_count_threshold = optional(number, null)
      interval_seconds        = optional(number, null) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
      path                    = optional(string, null)
      timeout                 = optional(number, null)
    }), {})
  })
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "key_vault_key_id" {
  type        = string
  default     = null
  description = "Used for container registry encryption"
}

variable "virtual_network_config" {
  type = object({
    address_spaces = optional(list(string), null)
  })
  default = {}
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

locals {
  default_name = "${var.project}-${var.environment}"
}

data "azurerm_user_assigned_identity" "main" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}
