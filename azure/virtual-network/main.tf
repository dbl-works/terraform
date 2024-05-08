data "azurerm_virtual_network" "main" {
  count = var.vnet_name != null && !var.create_vnet ? 1 : 0

  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  count = var.create_vnet ? 1 : 0

  name                = coalesce(var.vnet_name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = coalesce(var.tags, local.default_tags)
}

locals {
  vnet = var.create_vnet ? azurerm_virtual_network.main[0] : data.azurerm_virtual_network.main[0]
}

output "name" {
  value = local.vnet.name
}

output "id" {
  value = local.vnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "db_subnet_id" {
  value = "" # azurerm_subnet.db.id
}
