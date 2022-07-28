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
# =============== VPC ================ #


# =============== Elasticache ================ #
variable "elasticache_node_type" {
  type    = string
  default = "cache.t3.micro"
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

# Number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them
# If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off.
variable "elasticache_snapshot_retention_limit" {
  type    = number
  default = 0
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
# =============== ECS ================ #
