variable "account_id" {}
variable "project" {}
variable "environment" {}
variable "eip" {}

variable "ami_id" {}
variable "cidr_block" {}
variable "key_name" {}

variable "region" { default = "eu-central-1" }
variable "instance_type" { default = "t3.micro" }
