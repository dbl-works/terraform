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
  default = 1
}

variable "alternative_domains" {
  default = []
  type    = list(string)
}

variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}
