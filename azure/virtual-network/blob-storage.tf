# https://dev.to/agsouthernt/creating-a-private-endpoint-for-azure-storage-account-using-terraform-1f3g
resource "azurerm_private_dns_zone" "blob-storage" {
  count = var.enable_blob_storage_privatelink ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "blob-storage" {
  count = var.enable_blob_storage_privatelink ? 1 : 0

  name                = "blob-storage-private-endpoint-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_service_connection {
    name                           = "blob-storage-private-connection-${local.default_suffix}"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-${local.default_suffix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob-storage[0].id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count = var.enable_blob_storage_privatelink ? 1 : 0

  name                  = "virtual-network-link-${local.default_suffix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob-storage[0].name
  virtual_network_id    = azurerm_virtual_network.main.id
}

resource "azurerm_private_dns_a_record" "main" {
  count = var.enable_blob_storage_privatelink ? 1 : 0

  name                = "private-dns-a-record-${local.default_suffix}"
  zone_name           = azurerm_private_dns_zone.blob-storage[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.blob-storage.0.private_service_connection.0.private_ip_address]
}

