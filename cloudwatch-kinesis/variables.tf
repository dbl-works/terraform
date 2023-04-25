locals {
  ecs_cluster_name = var.ecs_cluster_name == null ? "${var.project}-${var.environment}" : var.ecs_cluster_name
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}


# Regional allows clusters with the same name to be in multiple regions
variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ecs_cluster_name" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "ecs_http_port" {
  type    = number
  default = 5073
}
