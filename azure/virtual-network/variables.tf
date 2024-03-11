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
  type = string
}

variable "private_subnet_config" {
  type = object({
    priority                   = number
    direction                  = string // Inbound, Outbound
    access                     = optional(string, "Allow")
    protocol                   = optional(string, "Tcp")
    source_port_range          = string // "*"
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })
  default = null
}

variable "public_subnet_config" {
  type = object({
    priority                   = number
    direction                  = string // Inbound, Outbound
    access                     = optional(string, "Allow")
    protocol                   = optional(string, "Tcp")
    source_port_range          = string // "*"
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })
  default = null
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
