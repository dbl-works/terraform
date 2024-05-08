# data "azurerm_key_vault" "main" {
#   count = var.privatelink_config.key_vault_name == null ? 0 : 1
#
#   name                = var.privatelink_config.key_vault_name
#   resource_group_name = var.resource_group_name
# }
#
# resource "azurerm_private_dns_zone" "key-vault" {
#   count = var.privatelink_config.key_vault_name == null ? 0 : 1
#
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = var.resource_group_name
#
#   tags = local.default_tags
# }
#
# resource "azurerm_private_endpoint" "key-vault" {
#   count = var.privatelink_config.key_vault_name == null ? 0 : 1
#
#   name                = "pe-${var.privatelink_config.key_vault_name}-kv"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.private.id
#
#   private_dns_zone_group {
#     name                 = azurerm_private_dns_zone.key-vault[0].name
#     private_dns_zone_ids = [azurerm_private_dns_zone.key-vault[0].id]
#   }
#
#   private_service_connection {
#     name                           = "pe-kv-${local.default_suffix}"
#     private_connection_resource_id = data.azurerm_key_vault.main[0].id
#     # If you are trying to connect the Private Endpoint to a remote resource without having the correct RBAC permissions on the remote resource set this value to true.
#     # NOTE/@TODO: RBAC permissions is not encouraged by some policy, you might need to set it to true if there is no relevant RBAC permissions on Key vault
#     is_manual_connection = false
#     subresource_names    = ["Vault"]
#   }
#
#   tags = local.default_tags
# }
#
# # The azurerm_private_dns_zone_virtual_network_link resource allows you to link a virtual network to this DNS zone
# # https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
# resource "azurerm_private_dns_zone_virtual_network_link" "key-vault" {
#   count = var.privatelink_config.key_vault_name == null ? 0 : 1
#
#   name                  = "vnl-${var.privatelink_config.key_vault_name}-kv"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.key-vault[0].name
#   virtual_network_id    = local.vnet.id
#
#   tags = local.default_tags
# }
