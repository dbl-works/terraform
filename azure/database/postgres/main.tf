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
