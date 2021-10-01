variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_ids" { type = list(string) }
variable "availability_zones" { type = list(string) }

variable "node_type" { default = "cache.t3.micro" }

variable "node_count" {
  type    = number
  default = 1
}
# variable "engine_version" { default = "6.x" }
