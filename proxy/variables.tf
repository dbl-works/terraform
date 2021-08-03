variable "account_id" {}
variable "environment" {}
variable "certificate_arn" {}
variable "public_ip" {}

variable "project" { default = "ssh-proxy" }
variable "cidr_block" { default = "10.6.0.0/16" }
variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}
