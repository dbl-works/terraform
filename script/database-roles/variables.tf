variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "bastion_subdomain" {
  type    = string
  default = "bastion"
}

variable "db_identifier" {
  type = string
}
