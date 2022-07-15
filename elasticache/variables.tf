variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "kms_key_arn" {}
variable "subnet_ids" { type = list(string) }
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
  type    = string
  default = "default.redis6.x"
}

variable "engine_version" {
  type    = string
  default = "6.x"
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

variable "data_tiering_enabled" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = null
}

locals {
  elasticache_name = var.name == null ? "${var.project}-${var.environment}-elasticache" : "${var.project}-${var.environment}-${var.name}-elasticache"
  cluster_name     = var.name == null ? "${var.project}-${var.environment}" : "${var.project}-${var.environment}-${var.name}"
}
