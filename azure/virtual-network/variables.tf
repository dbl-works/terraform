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

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
