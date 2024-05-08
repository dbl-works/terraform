# data "azurerm_storage_account" "main" {
#   count = var.privatelink_config.storage_account_name == null ? 0 : 1
#
#   name                = var.privatelink_config.storage_account_name
#   resource_group_name = var.resource_group_name
# }
#
# # https://dev.to/agsouthernt/creating-a-private-endpoint-for-azure-storage-account-using-terraform-1f3g
# resource "azurerm_private_dns_zone" "storage-account" {
#   count = var.privatelink_config.storage_account_name == null ? 0 : 1
#
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = var.resource_group_name
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
# resource "azurerm_private_endpoint" "storage-account" {
#   count = var.privatelink_config.storage_account_name == null ? 0 : 1
#
#   name                = "pe-${var.privatelink_config.storage_account_name}-blob"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   subnet_id           = azurerm_subnet.private.id
#
#   private_service_connection {
#     name                           = "pe-${var.privatelink_config.storage_account_name}-blob"
#     private_connection_resource_id = data.azurerm_storage_account.main[0].id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }
#
#   private_dns_zone_group {
#     name                 = azurerm_private_dns_zone.storage-account[0].name
#     private_dns_zone_ids = [azurerm_private_dns_zone.storage-account[0].id]
#   }
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
# resource "azurerm_private_dns_zone_virtual_network_link" "storage-account" {
#   count = var.privatelink_config.storage_account_name == null ? 0 : 1
#
#   name                  = "vnl-sa-${var.privatelink_config.storage_account_name}"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.storage-account[0].name
#   virtual_network_id    = local.vnet.id
#
#   tags = coalesce(var.tags, local.default_tags)
# }

# resource "azurerm_private_dns_a_record" "blob-storage" {
#   count = var.enable_blob_storage_privatelink ? 1 : 0
#
#   name                = "private-dns-a-record-${local.default_suffix}"
#   zone_name           = azurerm_private_dns_zone.blob-storage[0].name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.blob-storage.0.private_service_connection.0.private_ip_address]
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
