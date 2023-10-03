variable "account_id" {}
variable "vpc_id" {}
variable "region" {} # TODO: Could this be determined from VPC?
variable "subnet_ids" {}
variable "kms_key_arn" {}
variable "project" {}
variable "environment" {}

variable "instance_class" { default = "db.t3.micro" }
variable "engine_version" {
  default = "14"
  type    = string
}
variable "allocated_storage" { default = 100 }

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "parameter_group_name" {
  type    = string
  default = null
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "snapshot_identifier" {
  type    = string
  default = null
}

# Credentials for the root RDS user
# Only to be used in initial setup, never by applications
variable "username" {
  default   = "root"
  sensitive = true
}
variable "password" {
  sensitive = true
}

# Allow traffic from CIDR blocks
# e.g. 0.0.0.0/0 would allow all traffic
#      10.0.0.0/16 would allow all traffic from 10.0.x.x
#      1.2.3.4/32 would allow traffic from 1.2.3.4 only
variable "allow_from_cidr_blocks" { default = [] }

variable "allow_from_security_groups" {
  description = "Security groups which RDS allow traffics from"
  default     = []
}


## Read replica mode
variable "master_db_instance_arn" {
  default = null
  type    = string
}

variable "is_read_replica" {
  type    = bool
  default = false
}

variable "regional" {
  default = false
  type    = bool
}

# A custom name overrides the default {project}-{environment} convention
variable "name" {
  type        = string
  description = "Custom name for resources. Must be unique per account if deploying to multiple regions."
  default     = null
}

variable "enable_replication" {
  type        = bool
  description = "Enables logical replication of the database."
  default     = false
}

variable "subnet_group_name" {
  type    = string
  default = null
}

variable "delete_automated_backups" {
  type    = bool
  default = true
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

locals {
  name = var.name != null ? var.name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
}

variable "log_min_duration_statement" {
  type        = number
  default     = 3000
  description = "Used to log SQL statements that run longer than a specified duration of time (in ms)."
}

variable "log_retention_period" {
  type        = number
  default     = 4320
  description = "Controls how long automatic RDS log files are retained before being deleted (in min, must be between 1440-10080 (1-7 days)."
}
