resource "azurerm_private_dns_zone" "key-vault" {
  count = var.enable_key_vault_privatelink ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_private_endpoint" "key_vault" {
  count = var.enable_key_vault_privatelink ? 1 : 0

  name                = "key-vault-private-endpoint-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private.id

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.key-vault[0].name
    private_dns_zone_ids = [azurerm_private_dns_zone.key-vault[0].id]
  }

  private_service_connection {
    name                           = "key-vault-private-connection-${local.default_suffix}"
    private_connection_resource_id = var.key_vault_id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  tags = coalesce(var.tags, local.default_tags)
}
