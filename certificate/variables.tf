variable "environment" {}
variable "project" {}
variable "domain_name" {}

variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}

variable "configuration_aliases" {
  type    = list(any)
  default = []
}
