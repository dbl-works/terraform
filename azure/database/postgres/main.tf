resource "azurerm_postgresql_flexible_server" "main" {
  name                   = local.name
  resource_group_name    = var.resource_group_name
  location               = var.region
  version                = var.postgres_version
  delegated_subnet_id    = azurerm_subnet.main.id
  private_dns_zone_id    = azurerm_private_dns_zone.main.id
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  create_mode            = var.create_mode
  storage_mb             = var.storage_mb
  storage_tier           = var.storage_tier
  sku_name               = var.sku_name

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [1]

    content {
      key_vault_key_id                     = var.customer_managed_key.key_vault_key_id
      primary_user_assigned_identity_id    = var.customer_managed_key.primary_user_assigned_identity_id
      geo_backup_user_assigned_identity_id = var.customer_managed_key.geo_backup_user_assigned_identity_id
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  lifecycle {
    ignore_changes = [
      zone,
      tags
    ]
  }

  tags = local.default_tags
}

output "id" {
  value = azurerm_postgresql_flexible_server.main.id
}

output "fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}
