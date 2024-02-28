# Azure Postgres Database

https://azure.microsoft.com/en-us/pricing/details/postgresql/flexible-server/

```
locals {
  region = "West Europe"
  resource_group_name = "facebook-staging"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.region
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = local.resource_group_name
  location            = local.region
  name                = local.name

  tags = local.default_tags
}

module "database" {
  source = "github.com/dbl-works/terraform//azure/database/postgres"

  resource_group_name        = local.resource_group_name
  environment                = "staging"
  region                     = local.region
  project                    = "facebook"
  administrator_login        = "db-user"
  administrator_password     = "db-password"

  # Optional
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  encryption_client_id       = azurerm_user_assigned_identity.main.client_id
  retention_in_days          = 7
  db_subnet_address_prefixes = ["10.0.1.0/24"]
}
```
