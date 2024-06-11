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

If you set the blob storage shared_key_access to false, you must set `storage_use_azuread` to true in the provider block. This ensure terraform to access the bucket using AD, not using a shared key.
Refer to this [issues]
(https://github.com/hashicorp/terraform-provider-azurerm/issues/25521) for more information.

```
provider "azurerm" {
  storage_use_azuread = true
  features {}
}
```
