resource "azurerm_monitor_metric_alert" "cpu" {
  name                = local.name
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_id]
  description         = "Action will be triggered when cpu usage is greater than ${var.cpu_percentage_threshold}"

  # https://learn.microsoft.com/en-us/azure/container-apps/metrics
  criteria {
    metric_namespace = "microsoft.app/containerapps"
    metric_name      = "UsageNanoCores"
    aggregation      = "Average"
    operator         = "GreaterThan"
    # CPU usage in nanocores (1,000,000,000 nanocores = 1 core)
    threshold = 1 * 1000 * 1000 * 1000 * var.cpu_percentage_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "memory" {
  name                = local.name
  resource_group_name = var.resource_group_name
  scopes              = [var.container_app_id]
  description         = "Action will be triggered when memory usage is greater than ${var.memory_percentage_threshold}"

  # https://learn.microsoft.com/en-us/azure/container-apps/metrics
  criteria {
    metric_namespace = "microsoft.app/containerapps"
    metric_name      = "WorkingSetBytes"
    aggregation      = "Average"
    operator         = "GreaterThan"
    # 1073741824 bytes = 1 GB
    threshold = var.current_memory_in_gb * var.memory_percentage_threshold * 1073741824
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}


resource "azurerm_monitor_action_group" "main" {
  name                = local.name
  resource_group_name = var.resource_group_name
  short_name          = local.name

  webhook_receiver {
    name                    = "slack-${local.name}"
    service_uri             = var.slack_webhook_url
    use_common_alert_schema = true
  }
}
