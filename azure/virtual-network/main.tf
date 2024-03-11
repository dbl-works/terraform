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

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "db_private_dns_zone_id" {
  value = azurerm_private_dns_zone.db.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}
