resource "azurerm_log_analytics_workspace" "main" {
  name                = local.name
  location            = var.resource_group_name
  resource_group_name = var.region
  sku                 = var.sku
  # The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730.
  retention_in_days = var.logs_retention_in_days

  tags = local.default_tags
}

module "blob-storage" {
  source = "../blob-storage"

  name                       = "${local.name}-monitoring"
  environment                = var.environment
  project                    = var.project
  region                     = var.region
  resource_group_name        = var.resource_group_name
  user_assigned_identity_ids = var.user_assigned_identity_ids

  lifecycle_rules = {
    name                                              = "monitoring-${local.name}"
    prefix_match                                      = ["insights-activity-logs/ResourceId=${var.target_resource_id}"]
    blob_types                                        = ["appendBlob"]
    delete_after_days_since_modification_greater_than = var.logs_retention_in_days
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = local.name
  target_resource_id         = var.target_resource_id # This could be an subscription id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  storage_account_id         = module.blob-storage.id

  # Check here for the list of Service/Category available for different resources
  # https://learn.microsoft.com/en-gb/azure/azure-monitor/essentials/resource-logs-schema#service-specific-schemas
  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

output "id" {
  value = azurerm_log_analytics_workspace.main.id
}
