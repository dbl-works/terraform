# This is the existing public network that allows internet access
resource "azurerm_subnet" "public" {
  name                 = coalesce(var.public_subnet_name, "${local.default_name}-public")
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  # (Assuming address space is 10.0.0.0/16)
  # i.e. 10.0.2.0/23: range 10.0.1.0 - 10.0.2.255
  address_prefixes = [cidrsubnet(var.address_space, 7, 1)]
}

resource "azurerm_network_security_group" "public" {
  name                = "${var.network_security_group_name_prefix}public${local.network_security_group_name_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_network_security_rule" "public" {
  count = length(var.public_subnet_config)

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public.name

  name                       = "public-subnet-rule-${count.index + 1}"
  priority                   = var.public_subnet_config[count.index].priority
  direction                  = var.public_subnet_config[count.index].direction
  access                     = var.public_subnet_config[count.index].access
  protocol                   = var.public_subnet_config[count.index].protocol
  source_port_range          = var.public_subnet_config[count.index].source_port_range
  destination_port_range     = var.public_subnet_config[count.index].destination_port_range
  source_address_prefix      = var.public_subnet_config[count.index].source_address_prefix
  destination_address_prefix = var.public_subnet_config[count.index].destination_address_prefix
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}
