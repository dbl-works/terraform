variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "kms_key_arn" {}
variable "subnet_ids" { type = list(string) }
variable "availability_zones" { type = list(string) }

variable "node_type" { default = "cache.t3.micro" }

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
  description = "Replicas per Shard."
}

variable "num_node_groups" {
  type        = number
  default     = 0
  description = "Number of Shards (nodes)."
}
