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

variable "name" {
  type    = string
  default = null
}

variable "sku_name" {
  type    = string
  default = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Must be either standard or premium"
  }
}

variable "key_type" {
  type    = string
  default = "RSA"

  # https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys
  validation {
    condition     = contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], var.key_type)
    error_message = "Must be either EC (Elliptic Curve), EC-HSM, RSA or RSA-HSM"
  }
}

variable "key_size" {
  type    = number
  default = 2048
}

# https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys-details#key-access-control
# Permissions for cryptographic operations

# decrypt: Use the key to unprotect a sequence of bytes
# encrypt: Use the key to protect an arbitrary sequence of bytes
# unwrapKey: Use the key to unprotect wrapped symmetric keys
# wrapKey: Use the key to protect a symmetric key
# verify: Use the key to verify digests
# sign: Use the key to sign digests
variable "key_opts" {
  type    = list(string)
  default = []
}

variable "retention_in_days" {
  type    = number
  default = 7
}

# https://en.wikipedia.org/wiki/ISO_8601#Durations
variable "rotate_before_expiry_in_days" {
  type    = string
  default = "30"
}

variable "expired_in_days" {
  type    = string
  default = "90"
}

variable "notify_before_expiry" {
  type    = string
  default = "90"
}

variable "user_ids" {
  type    = list(string)
  default = []
}

variable "key_vault_key_name" {
  type    = string
  default = null
}

variable "user_assigned_identity_name" {
  type = string
}

# TODO @sam: Reevaluate the name, eg. private endpoint? privatelink?
variable "privatelink_config" {
  type = object({
    subnet_id          = string
    virtual_network_id = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

locals {
  default_name = "${var.project}-${var.environment}"
}
