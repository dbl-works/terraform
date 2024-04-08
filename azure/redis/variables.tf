variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "redis_version" {
  type    = number
  default = 6 # The latest version Azure can support
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Redis size: (Basic/Standard: 1,2,3,4,5,6) (Premium: 1,2,3,4)  https://docs.microsoft.com/fr-fr/azure/redis-cache/cache-how-to-premium-clustering"
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "zones" {
  type = list(string)
}

variable "family" {
  type    = string
  default = "C"
}

variable "sku_name" {
  type        = string
  default     = "Standard"
  description = "Redis Cache Sku name. Can be Basic, Standard or Premium"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "resource_group_name" {
  type = string
}

variable "data_persistence_enabled" {
  type    = bool
  default = true
}

variable "data_persistence_frequency_in_minutes" {
  type    = number
  default = null
}

variable "data_persistence_max_snapshot_count" {
  type    = number
  default = null
}

variable "redis_additional_configuration" {
  description = "Additional configuration for the Redis instance. Some of the keys are set automatically. See https://www.terraform.io/docs/providers/azurerm/r/redis_cache.html#redis_configuration for full reference."
  type = object({
    aof_backup_enabled                      = optional(bool)
    aof_storage_connection_string_0         = optional(string)
    aof_storage_connection_string_1         = optional(string)
    enable_authentication                   = optional(bool)
    active_directory_authentication_enabled = optional(bool)
    maxmemory_reserved                      = optional(number)
    maxmemory_delta                         = optional(number)
    # "volatile-lru", "allkeys-lru", "volatile-lfu", "allkeys-lfu", "volatile-random", "allkeys-random", "volatile-ttl", "noeviction"
    maxmemory_policy                       = optional(string) # How Redis will select what to remove when maxmemory is reached. Defaults to volatile-lru.
    maxfragmentationmemory_reserved        = optional(number) # The max-memory delta for this Redis instance.
    rdb_backup_enabled                     = optional(bool)
    rdb_backup_frequency                   = optional(number)
    rdb_backup_max_snapshot_count          = optional(number)
    rdb_storage_connection_string          = optional(string)
    notify_keyspace_events                 = optional(string)
    storage_account_subscription_id        = optional(string)
    data_persistence_authentication_method = optional(string) # Preferred auth method to communicate to storage account used for data persistence
  })
  default = {}
}

variable "shard_count" {
  type        = number
  default     = 1
  description = "(Optional) Only available when using the Premium SKU The number of Shards to create on the Redis Cluster."
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "storage_name" {
  type    = string
  default = null
}

variable "data_persistence_storage_account_tier" {
  description = "Replication type for the Storage Account used for data persistence."
  type        = string
  default     = "Standard"
}

variable "data_persistence_storage_account_replication" {
  description = "Replication type for the Storage Account used for data persistence."
  type        = string
  default     = "GZRS"
}

