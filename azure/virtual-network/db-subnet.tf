resource "azurerm_network_security_group" "db" {
  name                = "db-${local.network_security_group_name_suffix}"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow Inbound"
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
  name                 = coalesce(var.db_subnet_name, "${local.default_name}-db-subnet")
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  # (Assuming address space is 10.0.0.0/16)
  # i.e. 10.0.200.0/24, range 10.0.200.0 - 10.0.200.255
  address_prefixes  = [cidrsubnet(var.address_space, 8, 200)]
  service_endpoints = ["Microsoft.Storage"]

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
  # TODO: Consider to rename to privatelink.postgres.database.azure.com
  name                = coalesce(var.db_dns_zone_name, "${local.default_name}.postgres.database.azure.com")
  resource_group_name = var.resource_group_name

  tags = coalesce(var.tags, local.default_tags)

  depends_on = [
    azurerm_subnet_network_security_group_association.db
  ]
}

# Must link private DNS zone your virtual network to enable access
resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "db"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = azurerm_virtual_network.main.id

  tags = coalesce(var.tags, local.default_tags)
}
