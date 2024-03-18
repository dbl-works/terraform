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

variable "blob_storage_config" {
  type = map(object({
    container_access_type           = optional(string, null)
    account_kind                    = optional(string, null)
    account_tier                    = optional(string, null)
    account_replication_type        = optional(string, null)
    public_network_access_enabled   = optional(bool, null)
    allow_nested_items_to_be_public = optional(bool, null)
    versioning_enabled              = optional(bool, null)
    static_website = optional(object({
      index_document     = string
      error_404_document = string
    }), null)
  }))
  default = {}
}

variable "container_registry_config" {
  type = object({
    name                          = optional(string, null)
    sku                           = optional(string, "Basic")
    retention_in_days             = optional(number, 14)
    public_network_access_enabled = optional(bool, false)
    admin_enabled                 = optional(bool, true)
  })
  default = {}
}

variable "database_config" {
  type = object({
    version      = optional(string, null)
    storage_mb   = optional(number, null)
    storage_tier = optional(string, null)
    sku_name     = optional(string, null)
  })
  default = {}
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
    name                         = optional(string, null)
    environment_variables        = optional(map(string), {})
    secret_variables             = optional(list(string), [])
    target_port                  = optional(number, null)
    exposed_port                 = optional(number, null)
    cpu                          = optional(number, 0.25)
    memory                       = optional(string, "0.5Gi")
    image_version                = optional(string, "latest")
    log_analytics_workspace_name = optional(string, null)
    logs_retention_in_days       = optional(number, null)
    # https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
    health_check_options = optional(object({
      port                    = optional(string, null)
      transport               = optional(string, null)
      failure_count_threshold = optional(number, null)
      interval_seconds        = optional(number, null) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
      path                    = optional(string, null)
      timeout                 = optional(number, null)
    }), {})
  })
}

variable "virtual_network_config" {
  type = object({
    address_spaces = optional(list(string), null)
  })
  default = {}
}

variable "key_vault_config" {
  type = object({
    name              = optional(string, null)
    retention_in_days = optional(number, 7)
    sku_name          = optional(string, "standard")
    key_type          = optional(string, "RSA")
    key_size          = optional(number, 2048)
    # https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys-details#key-access-control
    # Permissions for cryptographic operations

    # decrypt: Use the key to unprotect a sequence of bytes
    # encrypt: Use the key to protect an arbitrary sequence of bytes
    # unwrapKey: Use the key to unprotect wrapped symmetric keys
    # wrapKey: Use the key to protect a symmetric key
    # verify: Use the key to verify digests
    # sign: Use the key to sign digests
    key_opts = optional(list(string), [])
    # https://en.wikipedia.org/wiki/ISO_8601#Durations
    rotate_before_expiry_in_days = optional(string, "30")
    expired_in_days              = optional(string, "90")
    notify_before_expiry         = optional(string, "90")
  })
  default = {}

  # https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys
  validation {
    condition     = contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], var.key_vault_config.key_type)
    error_message = "Must be either EC (Elliptic Curve), EC-HSM, RSA or RSA-HSM"
  }

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_config.sku_name)
    error_message = "Must be either standard or premium"
  }
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

locals {
  name = "${var.project}-${var.environment}"
}
