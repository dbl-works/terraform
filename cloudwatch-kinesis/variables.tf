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
  type    = string
  default = null
}

variable "ecs_http_port" {
  type    = number
  default = 5073
}

variable "log_bucket_arn" {
  type        = string
  description = "destination s3 bucket which will store the logs"
}

variable "buffer_size_for_s3" {
  type        = number
  default     = 10
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the s3 bucket."
}

variable "buffer_interval_for_s3" {
  type        = number
  default     = 400
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the s3 bucket."
}

variable "buffer_size_for_http_endpoint" {
  type        = number
  default     = 1
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the http endpoint."
}

variable "buffer_interval_for_http_endpoint" {
  type        = number
  default     = 60
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the http endpoint."
}
