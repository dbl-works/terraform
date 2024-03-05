# Azure Observability

https://learn.microsoft.com/en-us/azure/azure-monitor/overview


Create sub-modules for e.g.:
 * monitors
 * alerts

```
locals {
  project = "facebook"
  environment = "staging"
  resource_group_name = "${local.project}-${local.environment}"
  region = "West Europe"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.region
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = local.resource_group_name
  location            = local.region
  name = local.name
}

module "container-app" {
  source = "github.com/dbl-works/terraform//azure/container-app"
  resource_group_name = local.resource_group_name
  project             = local.project
  environment         = local.environment
  environment_variables = {
    PORT = 3000
    RAILS_ENV = "staging"
  }
  secret_variables = ["DATABASE_URL", "SIDEKIQ_USERNAME"]
  target_port = 3000
  exposed_port = 3000
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  cpu                        = 0.25
  memory                     = "0.5Gi"
  image_version              = "latest"
  health_check_options = {
    port                    = 80
    transport               = "HTTP"
    failure_count_threshold = 5
    interval_seconds        = 5
    path                    = "/livez"
    timeout                 = 5
  }
}

module "alert" {
  source = "github.com/dbl-works/terraform//azure/observability/alerts"

  project     = local.project
  environment = local.environment
  resource_group_name = local.resource_group_name

  container_app_id = module.container-app.id
  cpu_percentage_threshold = 80
  current_memory_in_gb = 2
  memory_percentage_threshold = 80
  slack_webhook_url = "<slack-webhook-url>"

  depends_on = [
    azurerm_resource_group.main
  ]
}

module "monitors" {
  source = "github.com/dbl-works/terraform//azure/observability/monitors"

  project     = local.project
  environment = local.environment
  resource_group_name = local.resource_group_name
  region      = local.region

  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  target_resource_id = module.container-app.id

  depends_on = [
    azurerm_resource_group.main
  ]
}
```
