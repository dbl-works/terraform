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

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_root_password" {
  type      = string
  sensitive = true
}

variable "db_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}
