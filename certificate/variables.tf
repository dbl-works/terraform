# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate

variable "environment" {}
variable "project" {}
variable "domain_name" {}

variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}
