resource "azurerm_log_analytics_workspace" "main" {
  name                = coalesce(var.log_analytics_workspace_name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = var.logging_sku
  # The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730.
  retention_in_days = var.logs_retention_in_days

  tags = local.default_tags
}

# https://learn.microsoft.com/en-us/azure/container-apps/vnet-custom?tabs=bash%2Cazure-cli&pivots=azure-portal
resource "azurerm_container_app_environment" "main" {
  name                = local.default_name
  location            = var.region
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id       = var.subnet_id
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  tags                           = coalesce(var.tags, local.default_tags)
}

