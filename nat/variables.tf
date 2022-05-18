variable "project" {}
variable "environment" {}
variable "public_ips" {
  type = list(string)
}
variable "subnet_public_ids" {}
variable "subnet_private_ids" {}
variable "vpc_id" {}
