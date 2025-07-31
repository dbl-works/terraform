variable "vpc_id" {}
variable "subnet_ids" {}
variable "kms_key_arn" {}
variable "project" {}
variable "environment" {}
variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ca_cert_identifier" {
  default = "rds-ca-ecc384-g1"
  type    = string
}

variable "backup_retention_period" {
  default = 7
  type    = number
}

variable "instance_class" {
  default     = "db.serverless"
  type        = string
  description = "Instance class for Aurora cluster instances, e.g. 'db.serverless', 'db.t3.medium', 'db.r5.large'."
}

variable "max_capacity" {
  type        = number
  default     = 2.0
  description = "[db.serverless] Maximum capacity for serverless instances (e.g., 1.0, 1.5, 2.0, 2.5, etc.)."
}

variable "min_capacity" {
  type        = number
  default     = 0.0
  description = "[db.serverless] Minimum capacity for serverless instances (e.g., 0.0, 0.5, 1.0, 1.5, etc.). 0.0 means the DB can pause (expect some seconds cold-start)."
}

variable "seconds_until_auto_pause" {
  type        = number
  default     = 300
  description = "[db.serverless] Time in seconds until serverless instances automatically pause (from 5 minutes to 24 hours)."
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of Nodes in the Aurora cluster. Use 2 for separate writer/reader nodes."
}

variable "engine_version" {
  default     = "17.4"
  type        = string
  nullable    = false
  description = "Aurora PostgreSQL engine version (e.g., '16.4', '17.4')"
}

# Credentials for the root Aurora user
# Only to be used in initial setup, never by applications
variable "username" {
  default   = "root"
  sensitive = true
}
variable "password" {
  sensitive = true
}

# Allow traffic from CIDR blocks
variable "allow_from_cidr_blocks" { default = [] }

variable "allow_from_security_groups" {
  description = "Security groups which Aurora allow traffics from"
  default     = []
}

# A custom name overrides the default {project}-{environment} convention
variable "name" {
  type        = string
  description = "Custom name for resources. Must be unique per account if deploying to multiple regions."
  default     = null
}

variable "enable_replication" {
  type        = bool
  description = "Enables logical replication for zero-ETL integration."
  default     = false
}

variable "subnet_group_name" {
  type    = string
  default = null
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "final_snapshot_identifier" {
  type    = string
  default = null
}

variable "identifier" {
  type    = string
  default = null
}

variable "regional" {
  default = false
  type    = bool
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "DB snapshot to create Aurora cluster from"
}

variable "delete_automated_backups" {
  type        = bool
  default     = true
  description = "Whether to delete automated backups immediately after the DB cluster is deleted"
}

variable "log_min_duration_statement" {
  type        = number
  default     = -1
  description = "Used to log SQL statements that run longer than a specified duration of time (in ms)."
}

variable "log_min_error_statement" {
  type        = string
  default     = "panic"
  description = "Controls which SQL statements that cause an error condition are recorded in the server log."

  validation {
    condition     = contains(["debug5", "debug4", "debug3", "debug2", "debug1", "info", "notice", "warning", "error", "log", "fatal", "panic"], var.log_min_error_statement)
    error_message = "The valid values are [debug5, debug4, debug3, debug2, debug1, info, notice, warning, error, log, fatal, panic]"
  }
}
