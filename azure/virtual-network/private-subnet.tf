# Private subnet prevents incoming traffic.
resource "azurerm_subnet" "private" {
  name                 = coalesce(var.private_subnet_name, "${local.default_name}-private")
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  # (Assuming address space is 10.0.0.0) range 10.0.100.0 - 10.0.100.255
  # i.e. 10.0.100.0/24
  address_prefixes = [cidrsubnet(var.address_space, 8, 100)]
}

resource "azurerm_network_interface" "private" {
  name                = coalesce(var.network_interface_name, "${local.default_name}-private")
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = coalesce(var.network_interface_name, "${local.default_name}-ipconfig")
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.network_security_group_name_prefix}private${local.network_security_group_name_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)
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
