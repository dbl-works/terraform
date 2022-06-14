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

variable "availability_zones" { type = list(string) }

variable "parameter_group_name" {
  type    = string
  default = "default.redis6.x"
}

variable "engine_version" {
  type    = string
  default = "6.x"
}
