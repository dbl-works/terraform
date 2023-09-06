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

variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Must be greater than or equal to allocated_storage or 0 to disable Storage Autoscaling."
}

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
