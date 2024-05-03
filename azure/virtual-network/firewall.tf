resource "azurerm_public_ip" "main" {
  name                = "ip-${local.default_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_firewall" "main" {
  name                = "${local.default_suffix}-firewall"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.public.id
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_route_table" "main" {
  name                = "default"
  location            = var.region
  resource_group_name = var.resource_group_name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.main.id
}
