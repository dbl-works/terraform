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

variable "tls_settings" {
  type = object({
    min_tls_version          = optional(string, null)     # 1.0, 1.1, 1.2, 1.3
    tls_1_3                  = optional(string, "on")     # "on/off"
    automatic_https_rewrites = optional(string, "on")     # "on/off"
    ssl                      = optional(string, "strict") # "strict"
    always_use_https         = optional(string, "on")     # "on/off"
  })
  default = null
}

variable "kms_deletion_window_in_days" {
  type = number
}

# =============== KMS ================ #

variable "public_ips" {
  type    = list(string)
  default = []
}

variable "vpc_config" {
  type = object({
    availability_zones = optional(list(string), [])
    cidr_block         = string
    remote_cidr_blocks = optional(list(string), [])
  })
}

variable "elasticache_config" {
  type = object({
    transit_encryption_enabled   = optional(bool, true)
    name                         = optional(string, null)
    node_type                    = optional(string, "cache.t3.micro")
    major_version                = optional(number, 7)
    minor_version                = optional(number, 0)
    node_count                   = optional(number, 1)
    parameter_group_name         = optional(string, "default.redis7.cluster.on")
    replicas_per_node_group      = optional(number, 1)
    shards_per_replication_group = optional(number, 1)
    data_tiering_enabled         = optional(bool, false)
    multi_az_enabled             = optional(bool, true)
    snapshot_retention_limit     = optional(number, 0)
    cluster_mode                 = optional(bool, true)
    maxmemory_policy             = optional(string, null)
    automatic_failover_enabled   = optional(bool, true)
  })
}

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
    backup_retention_period         = optional(number, 7)
    storage_autoscaling_upper_limit = optional(number, 20)
    multi_az                        = optional(bool, null)
    delete_automated_backups        = optional(bool, true)
    skip_final_snapshot             = optional(bool, false)
    final_snapshot_identifier       = optional(string, null)
    log_min_duration_statement      = optional(number, -1)
    log_retention_period            = optional(number, 1440)
    log_min_error_statement         = optional(string, "panic")
    ca_cert_identifier              = optional(string, "rds-ca-ecc384-g1")
  })
}
