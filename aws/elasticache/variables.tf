variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "kms_key_arn" {}
variable "subnet_ids" { type = list(string) }

variable "allow_from_cidr_blocks" {
  type    = list(string)
  default = []
}

# deprecated
variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "Only required when cluster mode is disabled"
}

variable "node_type" { default = "cache.t3.micro" }

variable "node_count" {
  type        = number
  default     = 1
  description = "Only required when cluster mode is disabled"
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Use default.redis7.cluster.on, for Redis (cluster mode enabled) clusters and replication groups. Use default.redis7, for Redis (cluster mode disabled) clusters and replication groups."
}

variable "major_version" {
  type    = number
  default = 7
}

variable "minor_version" {
  type    = number
  default = 0
  validation {
    condition     = var.minor_version >= 0
    error_message = "minor_version must be between 0 or higher"
  }
}

variable "snapshot_retention_limit" {
  type    = number
  default = 0
}

variable "replicas_per_node_group" {
  type        = number
  default     = 1
  description = "Replicas per Shard. Only required when cluster mode is enabled"
}

variable "shard_count" {
  type        = number
  default     = 1
  description = "Number of Shards (nodes). Only required when cluster mode is enabled"
}

variable "cluster_mode" {
  type    = bool
  default = true
}

variable "transit_encryption_enabled" {
  type        = bool
  default     = true
  description = ":warning: changing this from `false` to `true` requires a re-creation of the cluster"
}

variable "transit_encryption_mode" {
  type        = string
  default     = "required"
  nullable    = true
  description = "when migrating from no encryption to encryption, this must be set to 'preferred', then apply changes, then set to 'required'"

  validation {
    condition     = var.transit_encryption_mode == null || var.transit_encryption_mode == "required" || var.transit_encryption_mode == "preferred"
    error_message = "transit_encryption_mode must be either 'required' or 'preferred'"
  }
}

variable "multi_az_enabled" {
  type    = bool
  default = true
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "data_tiering_enabled" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = null
}

variable "engine" {
  type    = string
  default = "redis"
  validation {
    condition     = contains(["redis", "valkey"], var.engine)
    error_message = "engine must be either 'redis' or 'valkey'"
  }
}

variable "maxmemory_policy" {
  type        = string
  default     = null
  description = "Only effective, when NOT passing a custom parameter group name"

  validation {
    condition     = var.maxmemory_policy == null || contains(["volatile-lru", "allkeys-lru", "volatile-lfu", "allkeys-lfu", "volatile-random", "allkeys-random", "volatile-ttl", "noeviction"], var.maxmemory_policy)
    error_message = "maxmemory_policy must be one of volatile-lru, allkeys-lru, volatile-lfu, allkeys-lfu, volatile-random, allkeys-random, volatile-ttl, noeviction"
  }
}

locals {
  elasticache_name = var.name == null ? "${var.project}-${var.environment}-elasticache" : "${var.project}-${var.environment}-${var.name}-elasticache"
  cluster_name     = var.name == null ? "${var.project}-${var.environment}" : "${var.project}-${var.environment}-${var.name}"
}
