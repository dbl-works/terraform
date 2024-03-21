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
  default_name = "${var.project}-${var.environment}"
}
