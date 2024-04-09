# VNet requirements: https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-vnet#what-are-some-common-misconfiguration-issues-with-azure-cache-for-redis-and-virtual-networks
# https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-vnet
resource "azurerm_subnet" "redis" {
  name                 = coalesce(var.redis_subnet_name, "${local.default_name}-redis-subnet")
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 150)]
}
