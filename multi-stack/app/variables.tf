variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "ecs_config" {
  type = object({
    allow_internal_traffic_to_ports   = optional(list(string), null)
    allow_alb_traffic_to_ports        = optional(list(string), null)
    grant_access_to_kms_arns          = optional(list(string), [])
    regional                          = optional(bool, null)
    keep_alive_timeout                = optional(string, null)
    grant_read_access_to_s3_arns      = optional(list(string), [])
    grant_write_access_to_s3_arns     = optional(list(string), [])
    grant_read_access_to_sqs_arns     = optional(list(string), [])
    grant_write_access_to_sqs_arns    = optional(list(string), [])
    ecs_custom_policies               = optional(list(any), [])
    monitored_service_groups          = optional(list(string), null)
    enable_container_insights         = optional(bool, null)
    enable_dashboard                  = optional(bool, null)
    cloudwatch_logs_retention_in_days = optional(number, null)
    secret_arns                       = optional(list(string), [])
    allowlisted_ssh_ips               = optional(list(string), null)
    service_discovery_enabled         = optional(bool, null)
    vpc_cidr_block                    = string
  })
}

variable "project_settings" {
  type = map(object({
    domain               = string
    private_buckets_list = optional(list(string), [])
    public_buckets_list  = optional(list(string), [])
    s3_cloudflare_records = optional(map(object({
      worker_script_name = string
    })), {})
    host_header       = optional(list(string), null)
    health_check_path = optional(string, null)
    health_check_options = optional(
      object({
        healthy_threshold   = optional(number, 2)  # The number of consecutive health checks successes required before considering an unhealthy target healthy.
        unhealthy_threshold = optional(number, 5)  # The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold.
        timeout             = optional(number, 30) # The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds.
        interval            = optional(number, 60) # The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds.
        matcher             = optional(string, "200,204,301,302")
        protocol            = optional(string, "HTTP")
      }), {}
    )
  }))
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

# =============== Cloudflare ================ #
variable "tls_settings" {
  type = object({
    tls_1_3                  = string # "on/off"
    automatic_https_rewrites = string # "on/off"
    ssl                      = string # "strict"
    always_use_https         = string # "on/off"
  })
  default = null
}
# =============== KMS ================ #
variable "kms_deletion_window_in_days" {
  type = number
}

# =============== KMS ================ #

# =============== NAT ================ #
variable "public_ips" {
  type    = list(string)
  default = []
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

# CIDR blocks from all regions that are not this region
variable "remote_cidr_blocks" {
  type    = list(string)
  default = []
}
# =============== VPC ================ #


# =============== Elasticache ================ #
variable "elasticache_transit_encryption_enabled" {
  type        = bool
  default     = true
  description = ":warning: changing this from `false` to `true` requires a re-creation of the cluster"
}

variable "elasticache_name" {
  type    = string
  default = null
}

variable "elasticache_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "elasticache_major_version" {
  type    = number
  default = 7
  validation {
    condition     = var.elasticache_major_version >= 6 && var.elasticache_major_version <= 7
    error_message = "elasticache major_version must be 6 or 7"
  }
}

variable "elasticache_minor_version" {
  type    = number
  default = 0
  validation {
    condition     = var.elasticache_minor_version >= 0
    error_message = "elasticache minor_version must be between 0 or higher"
  }
}

variable "elasticache_node_count" {
  type    = number
  default = 1
}

variable "elasticache_parameter_group_name" {
  type    = string
  default = "default.redis7.cluster.on"
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

variable "elasticache_automatic_failover_enabled" {
  type    = bool
  default = true
}
# =============== Elasticache ================ #
variable "rds_config" {
  type = object({
    name                            = optional(string, null)
    identifier                      = optional(string, null)
    multi_region_kms_key            = optional(bool, false)
    instance_class                  = optional(string, "db.t3.micro")
    engine_version                  = optional(string, "16")
    allocated_storage               = optional(number, 10)
    allow_from_cidr_blocks          = optional(list(string), [])
    subnet_group_name               = optional(string, null)
    backup_retention_period         = optional(7, number)
    storage_autoscaling_upper_limit = optional(number, 20)
    multi_az                        = optional(bool, null)
    delete_automated_backups        = optional(bool, true)
    skip_final_snapshot             = optional(bool, false)
    final_snapshot_identifier       = optional(string, null)
    log_min_duration_statement      = optional(number, -1)
    log_retention_period            = optional(number, 1440)
    log_min_error_statement         = optional(string, "panic")
    ca_cert_identifier              = optional("rds-ca-ecc384-g1", string)
  })
}
