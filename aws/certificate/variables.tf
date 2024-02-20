variable "environment" {}
variable "project" {}
variable "domain_name" {}

variable "alternative_domains" {
  default = []
  type    = list(string)
}
variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}
