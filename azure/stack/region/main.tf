# Per region service
resource "azurerm_network_watcher" "main" {
  name                = coalesce(var.network_watcher_name, var.region)
  location            = var.region
  resource_group_name = var.resource_group_name

  tags = var.tags
}
