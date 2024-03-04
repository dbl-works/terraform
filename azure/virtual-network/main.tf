resource "azurerm_virtual_network" "main" {
  name                = local.name
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = var.address_spaces
}

resource "azurerm_subnet" "main" {
  for_each = var.subnet_config

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "main" {
  for_each = var.subnet_config

  name                = each.key
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "main" {
  for_each = var.subnet_config

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main[each.key].name

  # TODO: Allow more rules
  name                       = "rule-1"
  priority                   = each.value.rules.priority
  direction                  = each.value.rules.direction
  access                     = each.value.rules.access
  protocol                   = each.value.rules.protocol
  source_port_range          = each.value.rules.source_port_range
  destination_port_range     = each.value.rules.destination_port_range
  source_address_prefix      = each.value.rules.source_address_prefix
  destination_address_prefix = each.value.rules.destination_address_prefix

}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnet_config

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}
