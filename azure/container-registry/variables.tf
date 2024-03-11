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

variable "admin_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

# Encryption can only be applied when using the Premium Sku.
variable "key_vault_key_id" {
  type    = string
  default = null
}

# Encryption can only be applied when using the Premium Sku.
variable "encryption_client_id" {
  type        = string
  description = "The client ID of the managed identity associated with the encryption key."
  default     = null
}

# ACR retention policy can only be applied when using the Premium Sku.
variable "retention_in_days" {
  type        = number
  default     = 7
  description = "The number of days to retain an untagged manifest after which it gets purged."
  nullable    = false
}

variable "sku" {
  type        = string
  description = "https://learn.microsoft.com/en-us/azure/container-registry/container-registry-skus"
  default     = "Standard"
  nullable    = false

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Must be either Basic, Standard, or Premium"
  }
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

locals {
  default_name = var.project # for security reasons, you should use the same registry name for all environments

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
