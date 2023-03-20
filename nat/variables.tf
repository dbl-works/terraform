variable "project" {}
variable "environment" {}
variable "public_ips" {}
variable "subnet_public_ids" {}
variable "subnet_private_ids" {}
variable "vpc_id" {}


locals {
  subnets_all = flatten(concat(
    var.subnet_public_ids,
    var.subnet_private_ids,
  ))
}
