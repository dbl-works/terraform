resource "azurerm_virtual_network" "main" {
  name                = coalesce(var.vnet_name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = coalesce(var.tags, local.default_tags)
}
