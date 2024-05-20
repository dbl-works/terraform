# TODO: Convert this into a module
resource "azurerm_private_dns_zone" "main" {
  count = var.privatelink_config == null ? 0 : 1

  # TODO: Revisit the naming
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_endpoint" "main" {
  count = var.privatelink_config == null ? 0 : 1

  name                = "pe-${azurerm_storage_account.main.name}-storage"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.privatelink_config.subnet_id

  private_service_connection {
    name                           = azurerm_storage_account.main.name
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.main[0].name
    private_dns_zone_ids = [azurerm_private_dns_zone.main[0].id]
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count = var.privatelink_config == null ? 0 : 1

  name                  = "vnl-${azurerm_storage_account.main.name}-storage"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.privatelink_config.virtual_network_id

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "main" {
  count = var.privatelink_config == null ? 0 : 1
  # TODO: Check name format
  name                = "dns-${azurerm_storage_account.main.name}-storage"
  zone_name           = azurerm_private_dns_zone.main[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.main[0].private_service_connection.0.private_ip_address]
}
