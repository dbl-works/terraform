variable "resource_group_name" {
  type = string
}

variable "name" {
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

variable "address_spaces" {
  type = list(string)
}

variable "subnet_config" {
  type = map(object({
    address_prefixes = optional(list(string), [])
    rules = optional(object({
      priority                   = number
      direction                  = string // Inbound, Outbound
      access                     = optional(string, "Allow")
      protocol                   = optional(string, "Tcp")
      source_port_range          = string // "*"
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }), {})
  }), {})
}

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
