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

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

variable "encryption_client_id" {
  type        = string
  description = "The client ID of the managed identity associated with the encryption key."
}

variable "retention_in_days" {
  type        = number
  default     = 7
  description = "The number of days to retain an untagged manifest after which it gets purged."
  nullable    = false
}

variable "sku" {
  type        = string
  description = "https://learn.microsoft.com/en-us/azure/container-registry/container-registry-skus"
  default     = "Basic"
  nullable    = false

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Must be either Basic, Standard, or Premium"
  }
}

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
