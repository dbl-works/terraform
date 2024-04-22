module "blob-storage" {
  source = "../../blob-storage"

  # https://github.com/hashicorp/terraform-provider-azurerm/issues/2977
  name                       = coalesce(var.blob_storage_name, "${var.project}${var.environment}monitoring")
  region                     = var.region
  resource_group_name        = var.resource_group_name
  user_assigned_identity_ids = var.user_assigned_identity_ids

  container_access_type = "private"
  account_kind          = "StorageV2"

  # Networking
  public_network_access_enabled = var.public_network_access_enabled
  allowed_ips                   = var.allowed_ips

  lifecycle_rules = {
    "monitoring-${coalesce(var.blob_storage_name, "${local.default_name}-monitoring")}" = {
      prefix_match                                      = ["insights-activity-logs/ResourceId=${var.container_app_environment_id}"]
      blob_types                                        = ["appendBlob"]
      delete_after_days_since_modification_greater_than = var.logs_retention_in_days
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = coalesce(var.monitor_diagnostic_setting_name, local.default_name)
  target_resource_id         = var.container_app_environment_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = module.blob-storage.storage_account_id

  # Check here for the list of Service/Category available for different resources
  # https://learn.microsoft.com/en-gb/azure/azure-monitor/essentials/resource-logs-schema#service-specific-schemas
  # https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/microsoft-app-managedenvironments-logs
  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
