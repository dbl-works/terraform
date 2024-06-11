# Issues with private endpoint: https://github.com/hashicorp/terraform-provider-azurerm/issues/23992
# Privatelink: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private-link
resource "azurerm_private_dns_zone" "main" {
  count = var.enable_privatelink ? 1 : 0

  name                = "${var.project}-${var.environment}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)
}

# TBD
# Issues with creating Postgresql: https://github.com/MicrosoftDocs/azure-docs/issues/119728
# resource "azurerm_private_endpoint" "main" {
#   count = var.enable_privatelink ? 1 : 0
#
#   name                = "pe-${var.db_name}-postgresqlServer"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.delegated_subnet_id
#
#   private_dns_zone_group {
#     name                 = azurerm_private_dns_zone.main[0].name
#     private_dns_zone_ids = [azurerm_private_dns_zone.main[0].id]
#   }
#
#   private_service_connection {
#     name                           = "pe-${var.db_name}-postgresqlServer"
#     private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
#     # If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC permissions on the remote resource set this value to true.
#     # NOTE/@TODO: RBAC permissions is not encouraged by some policy, you might need to set it to true if there is no relevant RBAC permissions on Key vault
#     is_manual_connection = false
#     # https://learn.microsoft.com/en-gb/azure/private-link/private-endpoint-overview#private-link-resource
#     subresource_names = ["postgresqlServer"]
#   }
#
#   tags = coalesce(var.tags, local.default_tags)
# }

# The azurerm_private_dns_zone_virtual_network_link resource allows you to link a virtual network to this DNS zone
# https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count = var.enable_privatelink ? 1 : 0

  name                  = "vnl-${var.db_name}-postgresqlServer"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.virtual_network_id

  tags = coalesce(var.tags, local.default_tags)
}
