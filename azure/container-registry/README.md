# Azure Container Registry

https://azure.microsoft.com/en-us/products/container-registry

### Example for Encrypted Container Registry
```
locals {
  region = "West Europe"
  resource_group_name = "facebook-staging"
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = local.resource_group_name
  location            = local.region

  name = local.name

  tags = local.default_tags
}

module "container-registry" {
  source = "github.com/dbl-works/terraform//azure/container-registry"

  resource_group_name        = local.resource_group_name
  environment                = "staging"
  region                     = local.region
  project                    = "facebook"
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  encryption_client_id       = azurerm_user_assigned_identity.main.client_id
  retention_in_days          = 7
}
```

### Pricing
- https://azure.microsoft.com/en-us/pricing/details/container-registry/
