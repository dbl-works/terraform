variable "account_id" {}
variable "project" {}
variable "environment" {}
variable "eip" {}
variable "ami_id" {}
variable "cidr_block" {}
variable "key_name" {}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "availability_zones" {
  type    = list(any)
  default = null
}

# can't use variables inside other variables, so we need to define a local variable
locals {
  availability_zones = var.availability_zones == null ? ["${var.region}a", "${var.region}b", "${var.region}c"] : var.availability_zones
}
