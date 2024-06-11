# https://learn.microsoft.com/en-gb/azure/firewall/tutorial-firewall-deploy-portal

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet" # Firewall subnet must be named as AzureFirewallSubnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet.name
  # i.e. 10.0.150.0/24
  # 10.0.150.0 - 10.0.150.254
  address_prefixes = [cidrsubnet(var.address_space, 8, 150)]
}

resource "azurerm_public_ip" "firewall" {
  name                = "firewall-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = coalesce(var.tags, local.default_tags)
}

# When you create a route for outbound and inbound connectivity through the firewall,
# a default route to 0.0.0.0/0 with the virtual appliance private IP as a next hop is sufficient.
# This directs any outgoing and incoming connections through the firewall.
# As an example, if the firewall is fulfilling a TCP-handshake and responding to an incoming request,
# then the response is directed to the IP address who sent the traffic.
resource "azurerm_firewall" "main" {
  name                = "firewall-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name = "configuration"

    # Reference to the subnet associated with the IP Configuration.
    # NOTE: The Subnet used for the Firewall must have the name AzureFirewallSubnet and the subnet mask must be at least a /26.
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = coalesce(var.tags, local.default_tags)
}

# TODO: Firewall cannot be deployed with Container App: https://github.com/microsoft/azure-container-apps/issues/227
# resource "azurerm_route_table" "main" {
#   name                = "default"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#
#   route {
#     name                   = "firewall-dg"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
#   }
#
#   tags = var.tags
# }
#
# resource "azurerm_subnet_route_table_association" "private" {
#   subnet_id      = azurerm_subnet.private.id
#   route_table_id = azurerm_route_table.main.id
# }
