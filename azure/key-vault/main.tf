data "azurerm_user_assigned_identity" "main" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = coalesce(var.name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  # NOTE: Always set the public network access to true so that we can perform the terraform changes
  # This is a hack to overcome the limitation of terraform
  # TODO: Find a better and official recommended solution
  public_network_access_enabled = var.public_network_access_enabled

  # Customer managed key require us to enable soft delete and purge protection.
  purge_protection_enabled   = true
  soft_delete_retention_days = var.retention_in_days
  tags                       = var.tags
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_user_assigned_identity.main.tenant_id
  object_id    = data.azurerm_user_assigned_identity.main.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
    "Encrypt", # For secret management in container app
    "Decrypt", # For secret management in container app
  ]

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]

  storage_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "users" {
  for_each = toset(var.user_ids)

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_user_assigned_identity.main.tenant_id
  object_id    = each.key

  key_permissions = [
    "Create",
    "Delete",
    "List",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]

  storage_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_key" "main" {
  name         = coalesce(var.key_vault_key_name, local.default_name)
  key_vault_id = azurerm_key_vault.main.id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = length(var.key_opts) > 0 ? var.key_opts : [
    "unwrapKey",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P${var.rotate_before_expiry_in_days}D"
    }

    expire_after         = "P${var.expired_in_days}D"
    notify_before_expiry = "P${var.notify_before_expiry}D"
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_access_policy.users
  ]
}

output "id" {
  value = azurerm_key_vault.main.id
}

output "name" {
  value = azurerm_key_vault_key.main.name
}

output "key_id" {
  value = azurerm_key_vault_key.main.id
}
