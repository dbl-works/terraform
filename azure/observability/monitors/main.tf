resource "azurerm_log_analytics_workspace" "main" {
  name                = coalesce(var.log_analytics_workspace_name, local.default_name)
  location            = var.resource_group_name
  resource_group_name = var.region
  sku                 = var.sku
  # The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730.
  retention_in_days = var.logs_retention_in_days

  tags = local.default_tags
}

module "blob-storage" {
  source = "../../blob-storage"

  name                       = coalesce(var.blob_storage_name, "${local.default_name}-monitoring")
  environment                = var.environment
  project                    = var.project
  region                     = var.region
  resource_group_name        = var.resource_group_name
  user_assigned_identity_ids = var.user_assigned_identity_ids

  lifecycle_rules = {
    "monitoring-${coalesce(var.blob_storage_name, "${local.default_name}-monitoring")}" = {
      prefix_match                                      = ["insights-activity-logs/ResourceId=${var.container_app_id}"]
      blob_types                                        = ["appendBlob"]
      delete_after_days_since_modification_greater_than = var.logs_retention_in_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = coalesce(var.monitor_diagnostic_setting_name, local.default_name)
  target_resource_id         = var.container_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  storage_account_id         = module.blob-storage.storage_account_id

  # Check here for the list of Service/Category available for different resources
  # https://learn.microsoft.com/en-gb/azure/azure-monitor/essentials/resource-logs-schema#service-specific-schemas
  # https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/microsoft-app-managedenvironments-logs
  enabled_log {
    category = "ContainerAppConsoleLogs"
  }

  enabled_log {
    category = "ContainerAppSystemLogs"
  }
}

output "id" {
  value = azurerm_log_analytics_workspace.main.id
}
