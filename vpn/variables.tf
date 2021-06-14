variable "environment" { default = "production" }
variable "project" { default = "vpn" }
variable "description" { default = "VPN to connect through a static IP" }
variable "log_retention_in_days" { default = 30 }
variable "vpc_id" {}
variable "root_certificate_chain_arn" {}
variable "server_certificate_arn" {}
variable "client_cidr_block" {}
variable "vpc_public_subnet_id" {}
variable "vpc_general_network_cidr" {}
variable "eip_id" {}
