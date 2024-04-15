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
  name                = coalesce(var.name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  redis_version       = var.redis_version
  shard_count         = var.shard_count
  enable_non_ssl_port = false
  minimum_tls_version = var.minimum_tls_version

  # Network
  public_network_access_enabled = var.public_network_access_enabled
  subnet_id                     = var.subnet_id
  zones                         = var.zones
  # If you don't specify a static IP address, an IP address is chosen automatically.
  private_static_ip_address = var.private_static_ip_address

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  # Only needed if we want to backup data in storage account, eg. production environment
  redis_configuration {
    aof_backup_enabled                      = try(local.redis_config.aof_backup_enabled, null)
    aof_storage_connection_string_0         = try(local.redis_config.aof_storage_connection_string_0, null)
    aof_storage_connection_string_1         = try(local.redis_config.aof_storage_connection_string_1, null)
    enable_authentication                   = try(local.redis_config.enable_authentication, null)
    active_directory_authentication_enabled = try(local.redis_config.active_directory_authentication_enabled, null)
    maxmemory_reserved                      = try(local.redis_config.maxmemory_reserved, null)
    maxmemory_delta                         = try(local.redis_config.maxmemory_delta, null)
    maxmemory_policy                        = try(local.redis_config.maxmemory_policy, null)
    maxfragmentationmemory_reserved         = try(local.redis_config.maxfragmentationmemory_reserved, null)
    rdb_backup_enabled                      = try(local.redis_config.rdb_backup_enabled, null)
    rdb_backup_frequency                    = try(local.redis_config.rdb_backup_frequency, null)
    rdb_backup_max_snapshot_count           = try(local.redis_config.rdb_backup_max_snapshot_count, null)
    rdb_storage_connection_string           = try(local.redis_config.rdb_storage_connection_string, null)
    notify_keyspace_events                  = try(local.redis_config.notify_keyspace_events, null)
    storage_account_subscription_id         = try(local.redis_config.storage_account_subscription_id, null)
    data_persistence_authentication_method  = try(local.redis_config.data_persistence_authentication_method, null)
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

output "redis_config" {
  value = local.redis_config[*]
}

output "hostname" {
  value       = azurerm_redis_cache.main.hostname
  description = "The unique DNS name through which your Redis cache instance can be accessed"
}

output "primary_connection_string" {
  value       = azurerm_redis_cache.main.primary_connection_string
  description = "The connection string used to connect to the Azure Redis instance. Used for read and write operations."
}
