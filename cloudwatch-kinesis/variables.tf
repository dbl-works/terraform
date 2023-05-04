locals {
  ecs_cluster_name = var.ecs_cluster_name == null ? "${var.project}-${var.environment}" : var.ecs_cluster_name
  name             = "${var.project}-${var.environment}-http-endpoint"
  log_group_name   = "kinesis/${local.ecs_cluster_name}"
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
  default     = 1800 # 30 min
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

variable "enable_cloudwatch" {
  type    = bool
  default = false
}

variable "http_endpoint_url" {
  type    = string
  default = null
}

variable "access_key" {
  type      = string
  sensitive = true
  default   = null
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 7
}

variable "s3_backup_mode" {
  type        = string
  default     = "FailedDataOnly"
  description = "(Optional) Defines how documents should be delivered to Amazon S3. Valid values are FailedDataOnly and AllData"
}

variable "s3_kms_arn" {
  type = string
  # The default value is a dummy value because AWS performs some validations
  # on policies, hence we can't just use a blank string.
  default     = "arn:aws:kms:eu-central-1:*:key:can-t-be-blank"
  description = "(Optional) Required if the logs bucket are encrypted."
}
