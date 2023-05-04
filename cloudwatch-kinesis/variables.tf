locals {
  ecs_cluster_name = var.ecs_cluster_name == null ? "${var.project}-${var.environment}" : var.ecs_cluster_name
  name             = "${var.project}-${var.environment}-http-endpoint"
  log_group_name   = "/kinesis/${local.ecs_cluster_name}"
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
  default     = 1800 # 30 min
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the s3 bucket."
}

variable "enable_cloudwatch" {
  type    = bool
  default = false
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 7
}

variable "s3_kms_arn" {
  type = string
  # The default value is a dummy value because AWS performs some validations
  # on policies, hence we can't just use a blank string.
  default     = "arn:aws:kms:eu-central-1:*:key:can-t-be-blank"
  description = "(Optional) Required if the logs bucket are encrypted."
}

variable "kinesis_destination" {
  type    = string
  default = "http_endpoint"
}

variable "http_endpoint_configuration" {
  type = object({
    url                = string
    access_key         = optional(string, null)
    buffering_size     = number
    buffering_interval = number
    s3_backup_mode     = string
    enable_cloudwatch  = optional(bool, false)
    content_encoding   = optional(string, "NONE")
  })
  default = null
}
