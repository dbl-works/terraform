variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "account_id" {
  type = string
}

# =============== Certificate Manager ================ #
variable "domain_name" {
  type = string
}

variable "skip_cloudflare" {
  type    = bool
  default = false
}
# =============== Certificate Manager ================ #

# =============== S3 private ================ #
variable "private_buckets_list" {
  default = []
  type = set(object({
    bucket_name                     = string
    versioning                      = bool
    primary_storage_class_retention = number
    replicas = list(object({
      bucket_arn = string
      kms_arn    = string
      region     = string
    }))
  }))
}

# =============== S3 private ================ #

# =============== S3 public ================ #
variable "public_buckets_list" {
  default = []
  type = set(object({
    bucket_name                     = string
    versioning                      = bool
    primary_storage_class_retention = number
    replicas = list(object({
      bucket_arn = string
    }))
  }))
}
# =============== S3 public ================ #

# =============== KMS ================ #
variable "kms_deletion_window_in_days" {
  type = number
}

variable "kms_app_arn" {
  type = string
}
# =============== KMS ================ #

# =============== NAT ================ #
variable "public_ips" {
  type = list(string)
}
# =============== NAT ================ #

# =============== VPC ================ #
variable "vpc_availability_zones" {
  type    = list(string)
  default = []
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_peering" {
  type    = bool
  default = false
}

# CIDR blocks from all regions that are not this region
variable "remote_cidr_blocks" {
  type    = list(string)
  default = []
}
# =============== VPC ================ #


# =============== Elasticache ================ #
variable "elasticache_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "elasticache_parameter_group_name" {
  type    = string
  default = "default.redis6.x.cluster.on"
}

variable "elasticache_replicas_per_node_group" {
  type    = number
  default = 1
}

variable "elasticache_shards_per_replication_group" {
  type    = number
  default = 1
}

variable "elasticache_data_tiering_enabled" {
  type    = bool
  default = false
}

variable "elasticache_multi_az_enabled" {
  type    = bool
  default = true
}

# Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them
# If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off.
variable "elasticache_snapshot_retention_limit" {
  type    = number
  default = 0
}

variable "elasticache_cluster_mode" {
  type    = bool
  default = true
}

variable "elasticache_maxmemory_policy" {
  type    = string
  default = null
}
# =============== Elasticache ================ #

# =============== RDS ================ #
variable "rds_name" {
  type    = string
  default = null
}
# set the key for the master DB to multi-region if you have read replicas in other regions
variable "rds_multi_region_kms_key" {
  type    = bool
  default = false
}
variable "rds_is_read_replica" {
  type    = bool
  default = false
}
variable "rds_master_db_instance_arn" {
  default = null
  type    = string
}
variable "rds_master_db_vpc_cidr_block" {
  default = null
  type    = string
}
variable "rds_master_db_region" {
  type    = string
  default = null
}
variable "rds_master_db_vpc_id" {
  type    = string
  default = null
}
variable "rds_master_db_kms_key_arn" {
  type    = string
  default = null
}
variable "rds_master_nat_route_table_ids" {
  type    = list(string)
  default = []
}
variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "rds_engine_version" {
  type    = string
  default = "13"
}
variable "rds_allocated_storage" {
  type    = number
  default = 100
}
variable "rds_allow_from_cidr_blocks" {
  type    = list(string)
  default = []
}
# =============== RDS ================ #

# =============== ECS ================ #
variable "health_check_path" { default = "/livez" }
variable "allow_internal_traffic_to_ports" {
  type    = list(string)
  default = []
}

variable "ecs_name" {
  type    = string
  default = null
}

variable "allowlisted_ssh_ips" {
  type    = list(string)
  default = []
}

variable "grant_read_access_to_s3_arns" {
  default = []
}

variable "grant_write_access_to_s3_arns" {
  default = []
}

variable "grant_write_access_to_sqs_arns" {
  default = []
}

variable "grant_read_access_to_sqs_arns" {
  default = []
}

variable "ecs_custom_policies" {
  default = []
}

variable "secret_arns" {
  description = "arns of the secret manager that ECS can access"
  default     = []
}

variable "regional" {
  type    = bool
  default = true
}

variable "enable_xray" {
  type    = bool
  default = false
}
# =============== ECS ================ #

# =============== Cloudwatch ================ #
variable "cloudwatch_dashboard_view" {
  type = string
  # simple, detailed
  default = "simple"
}

variable "cloudwatch_sns_topic_arns" {
  type    = list(string)
  default = []
}

variable "metric_period" {
  type    = number
  default = 60
}

variable "alarm_period" {
  type    = number
  default = 300
}

variable "alarm_evaluation_periods" {
  type        = number
  default     = 1
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "cloudwatch_custom_metrics" {
  type    = list(any)
  default = []
}

variable "cloudwatch_elasticache_names" {
  type        = list(string)
  default     = []
  description = "Name of the elasticache cluster that needs to be monitored"
}

variable "cloudwatch_database_identifiers" {
  type        = list(string)
  default     = []
  description = "Identifiers of the databases that needs to be monitored"
}

variable "cloudwatch_alb_arn_suffixes" {
  type        = list(string)
  default     = []
  description = "Name of the load balancers that needs to be monitored"
}

variable "cloudwatch_cluster_names" {
  type        = list(string)
  default     = []
  description = "Name of the ECS cluster that needs to be monitored"
}

# https://aws.amazon.com/rds/instance-types/
variable "db_instance_class_memory_in_gb" {
  type = number
}

variable "datapoints_to_alarm" {
  type    = number
  default = 1
}
# =============== Cloudwatch ================ #
