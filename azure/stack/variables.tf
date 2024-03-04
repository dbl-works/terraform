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

variable "observability_config" {
  type = object({
    logs_retention_in_days = optional(string, null)
  })
}

variable "database_config" {
  type = object({
    version                    = optional(string, null)
    storage_mb                 = optional(number, null)
    storage_tier               = optional(string, null)
    sku_name                   = optional(string, null)
    retention_in_days          = optional(number, null)
    db_subnet_address_prefixes = optional(list(string), [])
  })
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
    environment_variables = optional(map(string), {})
    secret_variables      = optional(list(string), [])
    target_port           = optional(number, null)
    exposed_port          = optional(number, null)
    cpu                   = optional(number, 0.25)
    memory                = optional(string, "0.5Gi")
    image_version         = optional(string, "latest")
    # https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
    health_check_options = object({
      port                    = optional(string, 80)
      transport               = optional(string, "HTTP")
      failure_count_threshold = optional(number, 5)
      interval_seconds        = optional(number, 5) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
      path                    = optional(string, "/livez")
      timeout                 = optional(number, 5)
    }, {})
  })
}

variable "virtual_network_config" {
  type = object({
    address_spaces = optional(list(string), null)
  })
}

variable "key_vault_config" {
  type = object({
    retention_in_days = optional(number, 7)
    sku_name          = optional(string, "Standard")
    key_type          = optional(string, "EC")
    key_size          = optional(number, 2048)
    # https://en.wikipedia.org/wiki/ISO_8601#Durations
    rotate_before_expiry_in_days = optional(string, "30")
    expired_in_days              = optional(string, "90")
  })
  default = {}

  validation {
    condition     = contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], var.key_vault_config.key_type)
    error_message = "Must be either EC (Elliptic Curve), EC-HSM, RSA or RSA-HSM"
  }

  validation {
    condition     = contains(["Standard", "Premium"], var.key_vault_config.sku_name)
    error_message = "Must be either Standard or Premium"
  }
}

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
