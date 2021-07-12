variable "account_id" {}
variable "environment" {}
variable "ssl_certificate_arn" {}

variable "public_ips" {
  type = list(string)
}

variable "project" { default = "ssh-proxy" }
variable "health_check_path" { default = "/healthz" }
variable "cidr_block" { default = "10.6.0.0/16" }
variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}
