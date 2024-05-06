resource "azurerm_container_registry" "main" {
  name                          = coalesce(var.name, local.default_name)
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
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.main.id
    ]
  }

  dynamic "encryption" {
    for_each = var.sku == "Premium" ? [1] : []

    content {
      enabled            = true
      key_vault_key_id   = var.key_vault_key_id
      identity_client_id = var.encryption_client_id
    }
  }

  tags = coalesce(var.tags, local.default_tags)
}

data "azurerm_user_assigned_identity" "main" {
  name                = coalesce(var.user_assigned_identity_name, local.default_name)
  resource_group_name = var.resource_group_name
}

# TODO: Remove this
# resource "azurerm_role_assignment" "main" {
#   scope                = azurerm_container_registry.main.id
#   role_definition_name = "acrpull"
#   principal_id         = data.azurerm_user_assigned_identity.main.principal_id
# }

# TODO: Research on the lifecycle policy

output "id" {
  value = azurerm_container_registry.main.id
}

output "login_server" {
  value = azurerm_container_registry.main.login_server
}

output "name" {
  value = coalesce(var.name, local.default_name)
}
