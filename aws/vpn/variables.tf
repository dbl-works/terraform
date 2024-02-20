variable "project" {}
variable "environment" {}
variable "eip" {}
variable "ami_id" {}
variable "cidr_block" {}
variable "key_name" {}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "availability_zone" {
  type    = string
  default = null
}

data "aws_region" "current" {}

# can't use variables inside other variables, so we need to define a local variable
locals {
  availability_zone = var.availability_zone == null ? "${data.aws_region.current.name}a" : var.availability_zone
}
