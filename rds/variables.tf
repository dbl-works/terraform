variable "account_id" {}
variable "vpc_id" {}
variable "region" {} # TODO: Could this be determined from VPC?
variable "subnet_ids" {}
variable "kms_key_arn" {}
variable "project" {}
variable "environment" {}

variable "instance_class" { default = "db.t3.micro" }
variable "engine_version" { default = "13" }
variable "allocated_storage" { default = 100 }

variable "publicly_accessible" {
  type    = bool
  default = false
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
