resource "azurerm_container_registry" "main" {
  name                          = var.name == null ? var.project : var.name
  resource_group_name           = var.resource_group_name
  location                      = var.region
  sku                           = var.sku
  public_network_access_enabled = var.sku == "Premium" ? var.public_network_access_enabled : true
  anonymous_pull_enabled        = false
  admin_enabled                 = var.admin_enabled

  dynamic "retention_policy" {
    for_each = var.sku == "Premium" ? [1] : []

    content {
      days    = var.retention_in_days
      enabled = true
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  dynamic "encryption" {
    for_each = var.sku == "Premium" ? [1] : []

    content {
      enabled            = true
      key_vault_key_id   = var.key_vault_key_id
      identity_client_id = var.encryption_client_id
    }
  }

  tags = local.default_tags
}

# TODO: Research on the lifecycle policy

output "id" {
  value = azurerm_container_registry.main.id
}

output "login_server" {
  value = azurerm_container_registry.main.login_server
}

output "admin_username" {
  value = "Retrieve the credentials from Container Registry > Access Keys"
}
