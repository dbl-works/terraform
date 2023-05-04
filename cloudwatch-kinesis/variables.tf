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

variable "log_bucket_arn" {
  type        = string
  description = "destination s3 bucket which will store the logs"
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
    buffering_size     = optional(number, 1)
    buffering_interval = optional(number, 60)
    s3_backup_mode     = string
    enable_cloudwatch  = optional(bool, false)
    content_encoding   = optional(string, "NONE")
  })
  default = null
}

variable "s3_configuration" {
  type = object({
    s3_bucket_arn      = string
    buffering_size     = optional(number, 10) # Buffer incoming data to the specified size, in MBs, before delivering it to the s3 bucket.
    buffering_interval = optional(number, 1800) # Buffer incoming data for the specified period of time, in seconds, before delivering it to the s3 bucket.
    enable_cloudwatch  = optional(bool, false)
    compression_format = optional(string, "UNCOMPRESSED")
    aws_lambda_arn     = optional(string, null)
  })
  default = null
}

variable "subscription_log_group_name" {
  type = string
}

variable "kinesis_stream_name" {
  type    = string
  default = null
}
