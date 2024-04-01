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
    container_name                  = optional(string, null)
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
    name         = optional(string, null)
    version      = optional(string, null)
    storage_mb   = optional(number, null)
    storage_tier = optional(string, null)
    sku_name     = optional(string, null)
  })
  default = {}
}

variable "observability_config" {
  type = object({
    blob_storage_name = optional(string, null)
  })
  default = {}
}

variable "container_app_config" {
  type = object({
    name                  = optional(string, null)
    environment_variables = optional(map(string), {})
    # secret variables must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
    secret_variables             = optional(list(string), [])
    target_port                  = optional(number, null)
    exposed_port                 = optional(number, null)
    cpu                          = optional(number, 0.25)
    memory                       = optional(string, "0.5Gi")
    command                      = optional(list(string), null)
    image_version                = optional(string, "latest")
    log_analytics_workspace_name = optional(string, null)
    logs_retention_in_days       = optional(number, null)
    zone_redundancy_enabled      = optional(bool, null)
    custom_domain = optional(
      object({
        certificate_binding_type = optional(string, "SniEnabled")
        certificate_id           = string
        domain_name              = string
      }), null
    )
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
    address_spaces                      = optional(list(string), null)
    public_subnet_name                  = optional(string, null)
    private_subnet_name                 = optional(string, null)
    db_subnet_name                      = optional(string, null)
    db_network_security_group_name      = optional(string, null)
    public_network_security_group_name  = optional(string, null)
    private_network_security_group_name = optional(string, null)
    network_interface_name              = optional(string, null)
    db_dns_zone_name                    = optional(string, null)
  })
  default = {}
}

variable "tags" {
  type    = map(string)
  default = null
}

locals {
  default_name = "${var.project}-${var.environment}"
}

data "azurerm_user_assigned_identity" "main" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}
