# Azure Blob Storage

https://azure.microsoft.com/en-us/products/storage/blobs

```
locals {
  region = "West Europe"
  project = "facebook"
  resource_group_name = "facebook-staging"
  environment = "staging"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.region
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = local.resource_group_name
  location            = local.region
  name = local.name
  tags = local.default_tags

  depends_on = [
    azurerm_resource_group.main
  ]
}

# https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=terraform
# Example: Setting up terraform state bucket
module "blob-storage" {
  source = "github.com/dbl-works/terraform//azure/blob-storage"

  resource_group_name        = local.resource_group_name
  name                       = "${local.project}-${local.region}-${local.environment}-tfstate"
  region                     = local.region
  project                    = local.project
  environment                = local.environment
  allow_nested_items_to_be_public = false
  container_access_type      = "private"
  account_kind               = "StorageV2"
  account_tier               = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
  versioning_enabled = true
  cors_config = {}
}
```
