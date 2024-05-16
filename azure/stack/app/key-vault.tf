module "key-vault" {
  source = "../../key-vault"

  project = var.project
  environment = var.environment
  region = var.region
  user_assigned_identity_name = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name

  name              = var.key_vault_config.name
  retention_in_days = var.key_vault_config.retention_in_days
  sku_name          = var.key_vault_config.sku_name
  key_type          = var.key_vault_config.key_type
  key_size          = var.key_vault_config.key_size
  # https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys-details#key-access-control
  # Permissions for cryptographic operations

  # decrypt: Use the key to unprotect a sequence of bytes
  # encrypt: Use the key to protect an arbitrary sequence of bytes
  # unwrapKey: Use the key to unprotect wrapped symmetric keys
  # wrapKey: Use the key to protect a symmetric key
  # verify: Use the key to verify digests
  # sign: Use the key to sign digests
  key_opts = var.key_vault_config.key_opts
  # https://en.wikipedia.org/wiki/ISO_8601#Durations
  rotate_before_expiry_in_days = var.key_vault_config.rotate_before_expiry_in_days
  expired_in_days              = var.key_vault_config.expired_in_days
  notify_before_expiry         = var.key_vault_config.notify_before_expiry
  # User's object_ids who has access to the key vault
  user_ids                     = var.key_vault_config.user_ids
}
