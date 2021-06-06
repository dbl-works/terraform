variable "vpc_id" {}
variable "subnet_ids" {}
variable "kms_key_arn" {}
variable "project" {}
variable "environment" {}

variable "instance_class" { default = "db.t3.micro" }
variable "engine_version" { default = "13.2" }
variable "publicly_accessible" { default = false }
variable "allocated_storage" { default = 100 }

# Credentials for the root RDS user
# Only to be used in initial setup, never by applications
variable "username" { default = "root" }
variable "password" {}

# Allow traffic from CIDR blocks
# e.g. 0.0.0.0/0 would allow all traffic
#      10.0.0.0/16 would allow all traffic from 10.0.x.x
#      1.2.3.4/32 would allow traffic from 1.2.3.4 only
variable "allow_from_cidr_blocks" { default = [] }

# Allow traffic from security groups
variable "allow_from_security_groups" { default = [] }
