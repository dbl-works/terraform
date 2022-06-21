variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}

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

variable "eips_nat_count" {
  type    = number
  default = 1
}

variable "alternative_domains" {
  default = []
  type    = list(string)
}
