# Private subnet prevents incoming traffic.
resource "azurerm_subnet" "private" {
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  # (Assuming address space is 10.0.0.0) range 10.0.100.0 - 10.0.102.255
  address_prefixes = cidrsubnet(var.address_space, 8, count.index + 100)
}

resource "azurerm_network_interface" "private" {
  name                = "${local.name}-private"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${local.name}-ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_network_security_group" "private" {
  name                = "${local.name}-private"
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "private" {
  count = length(var.private_subnet_config)

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name

  name                       = "private-subnet-rule-${count.index + 1}"
  priority                   = var.private_subnet_config[count.index].priority
  direction                  = var.private_subnet_config[count.index].direction
  access                     = var.private_subnet_config[count.index].access
  protocol                   = var.private_subnet_config[count.index].protocol
  source_port_range          = var.private_subnet_config[count.index].source_port_range
  destination_port_range     = var.private_subnet_config[count.index].destination_port_range
  source_address_prefix      = var.private_subnet_config[count.index].source_address_prefix
  destination_address_prefix = var.private_subnet_config[count.index].destination_address_prefix

}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}
