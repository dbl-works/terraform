resource "azurerm_private_dns_zone" "key-vault" {
  count = var.privatelink_config == null ? 0 : 1

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_endpoint" "key-vault" {
  count = var.privatelink_config == null ? 0 : 1

  name                = "pe-${azurerm_key_vault.main.name}-kv"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.privatelink_config.subnet_id

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.key-vault[0].name
    private_dns_zone_ids = [azurerm_private_dns_zone.key-vault[0].id]
  }

  private_service_connection {
    name                           = "pe-kv-${azurerm_key_vault.main.name}"
    private_connection_resource_id = azurerm_key_vault.main.id
    # If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC permissions on the remote resource set this value to true.
    # NOTE/@TODO: RBAC permissions is not encouraged by some policy, you might need to set it to true if there is no relevant RBAC permissions on Key vault
    is_manual_connection = false
    subresource_names    = ["Vault"]
  }

  tags = var.tags
}

# The azurerm_private_dns_zone_virtual_network_link resource allows you to link a virtual network to this DNS zone
# https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
resource "azurerm_private_dns_zone_virtual_network_link" "key-vault" {
  count = var.privatelink_config == null ? 0 : 1

  name                  = "vnl-${azurerm_key_vault.main.name}-kv"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key-vault[0].name
  virtual_network_id    = var.privatelink_config.virtual_network_id

  tags = var.tags
}
