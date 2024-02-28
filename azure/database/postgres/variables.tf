variable "name" {
  type = string
}

variable "resource_group_name" {
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

variable "virtual_network_name" {
  type    = string
  default = null
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

variable "version" {
  type        = string
  default     = "16"
  description = "The version of PostgreSQL Flexible Server to use."
  nullable    = false
}

# The storage_mb can only be scaled up.
variable "storage_mb" {
  type     = number
  default  = 32768
  nullable = false
}

variable "storage_tier" {
  type    = string
  default = "P4"
  validation {
    condition     = contains(["P4", "P6", "P10", "P15", "P20", "P30", " P40", "P50", " P60", "P70", "P80"], var.storage_tier)
    error_message = "Must be either P4, P6, P10, P15,P20, P30,P40, P50,P60, P70 or P80."
  }
  nullable = false
}

variable "create_mode" {
  type     = string
  default  = "Default"
  nullable = false
}

variable "db_subnet_address_prefixes" {
  type     = list(string)
  default  = ["10.0.1.0/24"]
  nullable = false
}

# Name: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage#compute-tiers-vcores-and-server-types
variable "sku_name" {
  type        = string
  description = "The SKU Name for the PostgreSQL Flexible Server. Follows the tier + name pattern "
  default     = "GP_Standard_D4s_v3"
  nullable    = false
}

variable "administrator_login" {
  sensitive = true
  type      = string
}

variable "administrator_password" {
  sensitive = true
  type      = string
}

locals {
  name = "${var.project}-${var.environment}-${lower(replace(var.region, " ", "-"))}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
