variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "domain" {
  type = string
}

variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}

variable "is_read_replica_on_same_domain" {
  type    = bool
  default = false
}

variable "eips_nat_count" {
  type    = number
  default = 0
}

variable "alternative_domains" {
  default = []
  type    = list(string)
}

variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}


# in case this stack has a read-replica RDS, we need to access the master DB KMS key
variable "rds_cross_region_kms_key_arn" {
  type    = string
  default = null
}
