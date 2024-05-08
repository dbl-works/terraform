# https://learn.microsoft.com/en-gb/azure/firewall/tutorial-firewall-deploy-portal

# resource "azurerm_subnet" "firewall" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.main.name
#   # i.e. 10.0.150.0/24
#   # 10.0.150.0 - 10.0.150.254
#   address_prefixes = [cidrsubnet(var.address_space, 8, 150)]
# }
#
# resource "azurerm_public_ip" "firewall" {
#   name                = "firewall-${local.default_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
# resource "azurerm_firewall" "main" {
#   name                = "firewall-${local.default_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"
#
#   ip_configuration {
#     name = "configuration"
#
#     # Reference to the subnet associated with the IP Configuration.
#     # NOTE: The Subnet used for the Firewall must have the name AzureFirewallSubnet and the subnet mask must be at least a /26.
#     subnet_id            = azurerm_subnet.firewall.id
#     public_ip_address_id = azurerm_public_ip.firewall.id
#   }
# }
#
# resource "azurerm_route_table" "main" {
#   name                = "default"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#
#   route {
#     name                   = "default-route"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
#   }
#
#   tags = var.tags
# }
#
# resource "azurerm_subnet_route_table_association" "public" {
#   subnet_id      = azurerm_subnet.public.id
#   route_table_id = azurerm_route_table.main.id
# }
#
