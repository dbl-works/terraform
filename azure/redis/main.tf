locals {
  default_name = "${var.project}-${var.environment}-${lower(replace(var.region, " ", "-"))}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
  data_persistence_enabled = var.sku_name == "Premium" ? var.data_persistence_enabled : false

  default_redis_config = {
    rdb_backup_enabled            = local.data_persistence_enabled
    rdb_storage_connection_string = one(azurerm_storage_account.redis_storage[*].primary_blob_connection_string)
    rdb_backup_frequency          = local.data_persistence_enabled ? var.data_persistence_frequency_in_minutes : null
    rdb_backup_max_snapshot_count = local.data_persistence_enabled ? var.data_persistence_max_snapshot_count : null
  }

  redis_config = merge(local.default_redis_config, var.redis_additional_configuration)
}

resource "azurerm_redis_cache" "main" {
  name                          = coalesce(var.name, local.default_name)
  location                      = var.region
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  redis_version                 = var.redis_version
  shard_count                   = var.shard_count
  enable_non_ssl_port           = false
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  zones                         = var.zones

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  # Only needed if we want to backup data in storage account, eg. production environment
  dynamic "redis_configuration" {
    for_each = local.redis_config[*]
    content {
      aof_backup_enabled                      = redis_configuration.value.aof_backup_enabled
      aof_storage_connection_string_0         = redis_configuration.value.aof_storage_connection_string_0
      aof_storage_connection_string_1         = redis_configuration.value.aof_storage_connection_string_1
      enable_authentication                   = redis_configuration.value.enable_authentication
      active_directory_authentication_enabled = redis_configuration.value.active_directory_authentication_enabled
      maxmemory_reserved                      = redis_configuration.value.maxmemory_reserved
      maxmemory_delta                         = redis_configuration.value.maxmemory_delta
      maxmemory_policy                        = redis_configuration.value.maxmemory_policy
      maxfragmentationmemory_reserved         = redis_configuration.value.maxfragmentationmemory_reserved
      rdb_backup_enabled                      = redis_configuration.value.rdb_backup_enabled
      rdb_backup_frequency                    = redis_configuration.value.rdb_backup_frequency
      rdb_backup_max_snapshot_count           = redis_configuration.value.rdb_backup_max_snapshot_count
      rdb_storage_connection_string           = redis_configuration.value.rdb_storage_connection_string
      notify_keyspace_events                  = redis_configuration.value.notify_keyspace_events
      storage_account_subscription_id         = redis_configuration.value.storage_account_subscription_id
      data_persistence_authentication_method  = redis_configuration.value.data_persistence_authentication_method
    }
  }


  tags = coalesce(var.tags, local.default_tags)
}

resource "azurerm_storage_account" "redis_storage" {
  count = local.data_persistence_enabled ? 1 : 0

  name                = var.storage_name == null ? local.default_name : var.storage_name
  resource_group_name = var.resource_group_name
  location            = var.region

  account_tier             = var.data_persistence_storage_account_tier
  account_replication_type = var.data_persistence_storage_account_replication
  account_kind             = "StorageV2"

  min_tls_version = "TLS1_2"

  tags = coalesce(var.tags, local.default_tags)
}
