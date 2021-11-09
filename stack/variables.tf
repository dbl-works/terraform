variable "accont_id" {}
variable "project" {}
variable "environment" {}

variable "allowlisted_ssh_ips" { default = [] }
variable "availability_zones" { default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] }
variable "cidr_block" { default = "10.1.0.0/16" }
variable "region" { default = "eu-central-1" }
