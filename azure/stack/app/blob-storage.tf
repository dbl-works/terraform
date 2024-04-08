module "blob-storage" {
  for_each = var.blob_storage_config

  source = "../../blob-storage"

  resource_group_name             = var.resource_group_name
  name                            = each.key
  region                          = var.region
  container_name                  = each.value.container_name
  container_access_type           = each.value.container_access_type
  account_kind                    = each.value.account_kind
  account_tier                    = each.value.account_tier
  account_replication_type        = each.value.account_replication_type
  public_network_access_enabled   = each.value.public_network_access_enabled
  allow_nested_items_to_be_public = each.value.allow_nested_items_to_be_public
  versioning_enabled              = each.value.versioning_enabled
  tags                            = var.tags
}
