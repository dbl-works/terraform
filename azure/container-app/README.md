# Azure Container App

https://azure.microsoft.com/en-us/products/container-apps

```
locals {
  resource_group_name = "facebook"
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

  resource_group_name = var.resource_group_name
  project             = var.project
  environment         = var.environment

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
```
