variable "availability_zones" {
  type = list(string)
}
variable "environment" {}
variable "project" {}
variable "account_id" {}

variable "region" { default = "eu-central-1" }
variable "cidr_block" { default = "10.0.0.0/16" }
