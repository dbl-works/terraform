data "azurerm_virtual_network" "main" {
  name                = coalesce(var.virtual_network_name, "${var.project}-${var.environment}")
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "main" {
  name                = "${local.name}-db"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "${local.name}-db"
    priority                   = 1
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = 5432
    destination_port_range     = 5432
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.default_tags
}

resource "azurerm_subnet" "main" {
  name                 = "${local.name}-db-subnet"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = var.db_subnet_address_prefixes
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

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_private_dns_zone" "main" {
  name                = "${local.name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = local.default_tags

  depends_on = [
    azurerm_subnet_network_security_group_association.default
  ]
}
