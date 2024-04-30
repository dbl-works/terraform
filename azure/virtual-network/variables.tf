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

variable "db_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-db-subnet'."
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

# =================== Bastion Host ===================== #
variable "enable_bastion" {
  type    = bool
  default = true
}

# =================== Network Security Group name ===================== #
variable "network_security_group_name_suffix" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}
# =================== Network Security Group name ===================== #

variable "network_interface_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-ipconfig'."
}

variable "db_dns_zone_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

# =================== Enable Private Link ===================== #
variable "enable_blob_storage_privatelink" {
  type    = bool
  default = true
}

variable "enable_key_vault_privatelink" {
  type    = bool
  default = true
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "default_suffix" {
  type    = string
  default = null
}

variable "storage_account_id" {
  type    = string
  default = null
}

locals {
  default_name                       = "${var.project}-${var.environment}"
  default_suffix                     = coalesce(var.default_suffix, "${var.project}-${var.environment}")
  network_security_group_name_suffix = coalesce(var.network_security_group_name_suffix, "${var.project}-${var.environment}")

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
