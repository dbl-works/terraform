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
    priority                   = number
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
    priority                   = number
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

variable "public_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-public'."
}

variable "db_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-db-subnet'."
}

variable "db_network_security_group_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-db'."
}

variable "db_dns_zone_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

variable "private_subnet_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-private'."
}

variable "public_network_security_group_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-public'."
}

variable "private_network_security_group_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-private'."
}

variable "network_interface_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment-ipconfig'."
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
