resource "azurerm_virtual_network" "main" {
  name                = coalesce(var.vnet_name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = coalesce(var.tags, local.default_tags)
}

output "name" {
  value = azurerm_virtual_network.main.name
}

output "id" {
  value = azurerm_virtual_network.main.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}
