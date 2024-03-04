# Azure Stack

This includes all modules required for our standardized stack on Azure, which includes:

* container app
* container registriy
* postgres database
* observability (monitors & alerts)
* virtual network

Notes:

* default to smallest instance sizes
* default to having a single availability zone
* allow configuring two availability zones for production usage
* allow configuring larger instance sizes for production usage

```
locals {
  resource_group_name = "facebook"
  region = "West Europe"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.region
}

module "stack" {

}
```
