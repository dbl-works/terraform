resource "azurerm_private_endpoint" "main" {
  count = var.private_endpoint_config == null ? 0 : 1

  name                = "pe-${azurerm_container_registry.main.name}-containerRegistry"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_config.subnet_id

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.main[0].name
    private_dns_zone_ids = [azurerm_private_dns_zone.main[0].id]
  }

  private_service_connection {
    name                           = "pe-${azurerm_container_registry.main.name}-containerRegistry"
    private_connection_resource_id = azurerm_container_registry.main.id
    # If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC permissions on the remote resource set this value to true.
    # NOTE/@TODO: RBAC permissions is not encouraged by some policy, you might need to set it to true if there is no relevant RBAC permissions on Key vault
    is_manual_connection = false
    subresource_names    = ["Registry"]
  }

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_private_dns_zone" "main" {
  count = var.private_endpoint_config == null ? 0 : 1

  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)
}

# The azurerm_private_dns_zone_virtual_network_link resource allows you to link a virtual network to this DNS zone
# https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count = var.private_endpoint_config == null ? 0 : 1

  name                  = "vnl-${azurerm_container_registry.main.name}-containerRegistry"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.private_endpoint_config.virtual_network_id

  tags = coalesce(var.tags, local.default_tags)
}
