resource "azurerm_subnet" "db" {
  name                 = coalesce(var.db_subnet_name, "${local.default_name}-db-subnet")
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  # (Assuming address space is 10.0.0.0/16)
  # i.e. 10.0.200.0/24, range 10.0.200.0 - 10.0.200.255
  address_prefixes  = [cidrsubnet(var.address_space, 8, 200)]
  service_endpoints = ["Microsoft.Storage"]

  # Delegations enable the PostgreSQL service to perform tasks like configuring network settings,
  # applying security rules, and effectively managing the network interfaces that serve the database instances.
  # Without these permissions, the service wouldn't be able to correctly set up or manage the necessary network components.
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

# resource "azurerm_network_security_group" "db" {
#   name                = "${var.network_security_group_name_prefix}db${local.network_security_group_name_suffix}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#
#   security_rule {
#     name                       = "AllowInbound"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = 5432
#     destination_port_range     = 5432
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#
#   tags = merge(local.default_tags, {
#     # TODO: We are forced to add this to pass the validation
#     databricks-environment = false
#   })
# }
#
# The azurerm_network_watcher_flow_log creates a new storage lifecyle management rule that overwrites existing rules.
# Please make sure to use a storage_account with no existing management rules, until the issue is fixed.
resource "azurerm_network_watcher_flow_log" "db" {
  name                 = "${azurerm_network_security_group.db.name}-flow-log"
  network_watcher_name = var.network_watcher_name
  resource_group_name  = var.resource_group_name

  network_security_group_id = azurerm_network_security_group.db.id
  storage_account_id        = var.storage_account_for_network_logging
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 90
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = data.azurerm_log_analytics_workspace.main.workspace_id
    workspace_region      = data.azurerm_log_analytics_workspace.main.location
    workspace_resource_id = data.azurerm_log_analytics_workspace.main.id
    interval_in_minutes   = 10
  }

  tags = local.default_tags
}

# resource "azurerm_subnet_network_security_group_association" "db" {
#   subnet_id                 = azurerm_subnet.db.id
#   network_security_group_id = azurerm_network_security_group.db.id
# }

# resource "azurerm_private_dns_zone" "db" {
#   # TODO: Consider to rename to privatelink.postgres.database.azure.com
#   name                = coalesce(var.db_dns_zone_name, "${local.default_name}.postgres.database.azure.com")
#   resource_group_name = var.resource_group_name
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
# # Must link private DNS zone your virtual network to enable access
# resource "azurerm_private_dns_zone_virtual_network_link" "db" {
#   name                  = "db"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.db.name
#   virtual_network_id    = azurerm_virtual_network.main.id
#
#   tags = coalesce(var.tags, local.default_tags)
# }
#
