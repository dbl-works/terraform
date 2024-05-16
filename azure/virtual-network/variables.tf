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

variable "address_space" {
  type     = string
  default  = "10.0.0.0/16"
  nullable = false
}

variable "private_subnet_config" {
  type = list(object({
    priority                   = number # Start from 100
    direction                  = string // Inbound, Outbound
    access                     = optional(string, "Allow")
    protocol                   = optional(string, "Tcp")
    source_port_range          = string // "*"
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "public_subnet_config" {
  type = list(object({
    priority                   = number # Start from 100
    direction                  = string // Inbound, Outbound
    access                     = optional(string, "Allow")
    protocol                   = optional(string, "Tcp")
    source_port_range          = string // "*"
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "vnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

variable "create_vnet" {
  type    = bool
  default = false
}

# =================== Subnet name ===================== #
variable "public_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-public'."
}

variable "private_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-private'."
}

variable "redis_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-redis-subnet'."
}

variable "bastion_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-bastion-subnet'."
}

variable "network_watcher_name" {
  type = string
}

variable "storage_account_for_network_logging" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

# =================== Bastion Host ===================== #
variable "enable_bastion" {
  type    = bool
  default = true
}

# =================== Network Security Group name ===================== #
variable "network_security_group_name_prefix" {
  type    = string
  default = null
}

variable "network_security_group_name_suffix" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}
# =================== Network Security Group name ===================== #
variable "network_interface_name_prefix" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-'."
}

# =================== Enable Private Link ===================== #
variable "privatelink_config" {
  type = object({
    key_vault_name       = optional(string, null)
    storage_account_name = optional(string, null)
    database_name        = optional(string, null)
  })
  default = {}
}

variable "default_suffix" {
  type    = string
  default = null
}

locals {
  default_name                       = "${var.project}-${var.environment}"
  default_suffix                     = coalesce(var.default_suffix, "${var.project}-${var.environment}")
  network_security_group_name_suffix = coalesce(var.network_security_group_name_suffix, "-${var.project}-${var.environment}")

  default_tags = coalesce(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}
