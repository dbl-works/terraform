resource "azurerm_container_registry" "main" {
  name                          = var.project
  resource_group_name           = var.resource_group_name
  location                      = var.region
  sku                           = var.sku
  public_network_access_enabled = false
  anonymous_pull_enabled        = false

  retention_policy {
    days    = var.retention_in_days
    enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  encryption {
    enabled            = true
    key_vault_key_id   = data.azurerm_key_vault_key.main.id
    identity_client_id = var.encryption_client_id
  }

  tags = local.default_tags
}

data "azurerm_key_vault" "main" {
  name                = local.name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_key" "main" {
  name         = local.name
  key_vault_id = data.azurerm_key_vault.main.id
}
