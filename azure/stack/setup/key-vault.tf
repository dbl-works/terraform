data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = coalesce(var.key_vault_config.name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = var.key_vault_config.sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Customer managed key require us to enable soft delete and purge protection.
  purge_protection_enabled   = true
  soft_delete_retention_days = var.key_vault_config.retention_in_days
  tags                       = var.default_tags
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_user_assigned_identity.main.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
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
  for_each = toset(var.key_vault_config.user_ids)

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_user_assigned_identity.main.tenant_id
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
  key_type     = var.key_vault_config.key_type
  key_size     = var.key_vault_config.key_size

  key_opts = length(var.key_vault_config.key_opts) > 0 ? var.key_vault_config.key_opts : [
    "unwrapKey",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P${var.key_vault_config.rotate_before_expiry_in_days}D"
    }

    expire_after         = "P${var.key_vault_config.expired_in_days}D"
    notify_before_expiry = "P${var.key_vault_config.notify_before_expiry}D"
  }

  tags = var.default_tags

  depends_on = [
    azurerm_key_vault_access_policy.users
  ]
}

output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "key_vault_key_id" {
  value = azurerm_key_vault_key.main.id
}
