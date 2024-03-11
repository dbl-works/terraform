resource "azurerm_network_security_group" "db" {
  name                = "${local.default_name}-db"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "${local.default_name}-db"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = 5432
    destination_port_range     = 5432
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_subnet" "db" {
  name                 = "${local.default_name}-db-subnet"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 200)]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "DBflexibleServers"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_private_dns_zone" "db" {
  name                = "${local.default_name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)

  depends_on = [
    azurerm_subnet_network_security_group_association.db
  ]
}
