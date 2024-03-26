module "blob-storage" {
  source = "../../blob-storage"

  # https://github.com/hashicorp/terraform-provider-azurerm/issues/2977
  name                          = coalesce(var.blob_storage_name, "${var.project}${var.environment}monitoring")
  region                        = var.region
  resource_group_name           = var.resource_group_name
  user_assigned_identity_ids    = var.user_assigned_identity_ids

  # When setting public network access enabled to false, the following error will be thrown
  # containers.Client#GetProperties: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailure" Message="This request is not authorized to perform this operation.
  public_network_access_enabled = true
  container_access_type         = "private"
  account_kind                  = "StorageV2"

  lifecycle_rules = {
    "monitoring-${coalesce(var.blob_storage_name, "${local.default_name}-monitoring")}" = {
      prefix_match                                      = ["insights-activity-logs/ResourceId=${var.container_app_environment_id}"]
      blob_types                                        = ["appendBlob"]
      delete_after_days_since_modification_greater_than = var.logs_retention_in_days
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = "test"
  target_resource_id         = var.container_app_environment_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = module.blob-storage.storage_account_id

  # Check here for the list of Service/Category available for different resources
  # https://learn.microsoft.com/en-gb/azure/azure-monitor/essentials/resource-logs-schema#service-specific-schemas
  # https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/microsoft-app-managedenvironments-logs
  metric {
    category = "AllMetrics"
  }
}
