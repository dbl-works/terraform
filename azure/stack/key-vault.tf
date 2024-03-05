data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = local.name
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = var.key_vault_config.sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  soft_delete_retention_days = var.key_vault_config.retention_in_days
  tags                       = local.default_tags
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_user_assigned_identity.main.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  storage_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_key" "main" {
  name         = local.name
  key_vault_id = azurerm_key_vault.main.id
  key_type     = var.key_vault_config.key_type
  key_size     = var.key_vault_config.key_size

  # TODO: Figure out what permission is needed
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P${var.key_vault_config.rotate_before_expiry_in_days}D"
    }

    expire_after         = "P${var.key_vault_config.expired_in_days}D"
    notify_before_expiry = "P${var.key_vault_config.notify_before_expiry}D"
  }

  tags = local.default_tags
}


