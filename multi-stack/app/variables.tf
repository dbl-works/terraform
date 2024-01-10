variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "project_settings" {
  type = map(object({
    domain                          = string
    ecs_name                        = optional(string, null)
    skip_load_balancer              = optional(bool, true)
    allow_internal_traffic_to_ports = optional(list(string), [])
    allow_alb_traffic_to_ports      = optional(list(string), [])
    regional                        = optional(bool, false)
    grant_read_access_to_s3_arns    = optional(list(string), [])
    grant_write_access_to_s3_arns   = optional(list(string), [])
    grant_read_access_to_sqs_arns   = optional(list(string), [])
    grant_write_access_to_sqs_arns  = optional(list(string), [])
    ecs_custom_policies             = optional(list(any), [])
    secret_arns                     = optional(list(string), [])
    private_buckets_list            = optional(list(string), [])
    public_buckets_list             = optional(list(string), [])
  }))
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

# =============== Certificate Manager ================ #
variable "domain_name" {
  type = string
}

variable "skip_cloudflare" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type    = string
  default = null
}
# =============== Certificate Manager ================ #

# =============== Cloudflare ================ #
variable "s3_cloudflare_records" {
  type = map(object({
    worker_script_name = string
  }))
  default = {
    cdn = {
      worker_script_name = "serve-cdn"
    },
    app = {
      worker_script_name = "serve-app"
    }
  }
}

variable "tls_settings" {
  type = object({
    tls_1_3                  = string # "on/off"
    automatic_https_rewrites = string # "on/off"
    ssl                      = string # "strict"
    always_use_https         = string # "on/off"
  })
  default = null
}
# =============== Cloudflare ================ #

# =============== KMS ================ #
variable "kms_deletion_window_in_days" {
  type = number
}

variable "grant_access_to_kms_arns" {
  type    = list(string)
  default = []
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
variable "skip_elasticache" {
  type    = bool
  default = false
}

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

# =============== RDS ================ #
variable "skip_rds" {
  type    = bool
  default = false
}

variable "rds_name" {
  type    = string
  default = null
}

variable "rds_identifier" {
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
  default = 10
}
variable "rds_allow_from_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "rds_subnet_group_name" {
  type    = string
  default = null
}

variable "rds_backup_retention_period" {
  default = 7
  type    = number
}

variable "rds_storage_autoscaling_upper_limit" {
  type    = number
  default = 20
}

variable "rds_multi_az" {
  type        = bool
  description = "if no value is passed, multi-az will be set to true if the environment is production"
  default     = null
}

variable "rds_delete_automated_backups" {
  type    = bool
  default = true
}

variable "rds_skip_final_snapshot" {
  type    = bool
  default = false
}

variable "rds_final_snapshot_identifier" {
  type    = string
  default = null
}

variable "rds_log_min_duration_statement" {
  type        = number
  default     = -1
  description = "Used to log SQL statements that run longer than a specified duration of time (in ms)."
}

variable "rds_log_retention_period" {
  type        = number
  default     = 1440
  description = "Controls how long automatic RDS log files are retained before being deleted (in min, must be between 1440-10080 (1-7 days)."

  validation {
    condition     = var.rds_log_retention_period >= 1440 && var.rds_log_retention_period <= 10080
    error_message = "Log retention period must be between 1440-10080 (1-7 days)."
  }
}

variable "rds_log_min_error_statement" {
  type        = string
  default     = "panic"
  description = "Controls which SQL statements that cause an error condition are recorded in the server log."

  validation {
    condition     = contains(["debug5", "debug4", "debug3", "debug2", "debug1", "info", "notice", "warning", "error", "log", "fatal", "panic"], var.rds_log_min_error_statement)
    error_message = "The valid values are [debug5, debug4, debug3, debug2, debug1, info, notice, warning, error, log, fatal, panic]"
  }
}

variable "rds_ca_cert_identifier" {
  default     = "rds-ca-ecc384-g1"
  type        = string
  description = "The identifier of the CA certificate for the DB instance."
}
# =============== RDS ================ #

# =============== ECS ================ #
variable "health_check_path" { default = "/livez" }

variable "enable_container_insights" {
  type    = bool
  default = true
}

variable "health_check_options" {
  type = object({
    healthy_threshold   = optional(number, 2)  # The number of consecutive health checks successes required before considering an unhealthy target healthy.
    unhealthy_threshold = optional(number, 5)  # The number of consecutive health check failures required before considering the target unhealthy. For Network Load Balancers, this value must be the same as the healthy_threshold.
    timeout             = optional(number, 30) # The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers, the range is 2 to 120 seconds.
    interval            = optional(number, 60) # The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds.
    matcher             = optional(string, "200,204")
  })
  default = {}
}

variable "monitored_service_groups" {
  type        = list(string)
  default     = ["service:web"]
  description = "ECS service groups to monitor STOPPED containers."
}

variable "keep_alive_timeout" {
  type    = number
  default = 60
  validation {
    condition     = var.keep_alive_timeout >= 60 && var.keep_alive_timeout <= 4000
    error_message = "keep_alive_timeout must be between 60 and 4000"
  }
}

# variable "alb_listener_rules" {
#   type = list(object({
#     priority         = string
#     type             = string
#     target_group_arn = string
#     path_pattern     = optional(list(string), [])
#   }))
#   default = []
# }

variable "allowlisted_ssh_ips" {
  type    = list(string)
  default = []
}

variable "additional_certificate_arns" {
  description = "Additional certificates to add to the load balancer"
  default     = []

  type = list(object({
    name = string
    arn  = string
  }))
}

variable "rds_secret_manager_id" {
  type        = string
  description = "secret manager id which store the rds root user and root password"
}

variable "service_discovery_enabled" {
  type    = bool
  default = true
}
# =============== ECS ================ #

# =============== Cloudwatch ================ #
variable "cloudwatch_dashboard_view" {
  type = string
  # simple, detailed
  default = "simple"
}

variable "enable_cloudwatch_dashboard" {
  type    = bool
  default = true
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
  type        = number
  default     = null
  description = "Optional. Used for calculating the cloudwatch alarm threshold"
}

variable "datapoints_to_alarm" {
  type    = number
  default = 1
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 90
}
# =============== Cloudwatch ================ #
