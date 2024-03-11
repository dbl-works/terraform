resource "azurerm_virtual_network" "main" {
  name                = local.name
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = local.default_tags
}

output "name" {
  value = azurerm_virtual_network.main.name
}
