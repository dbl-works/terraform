variable "environment" {
  type = string
}

variable "project" {
  type = string
}

# Regional allows clusters with the same name to be in multiple regions
variable "regional" {
  type    = bool
  default = false
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 7
}

variable "kinesis_destination" {
  type    = string
  default = "http_endpoint"

  validation {
    condition     = contains(["s3", "http_endpoint"], var.kinesis_destination)
    error_message = "kinesis_destination must be either s3 or http_endpoint"
  }
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
    buffering_size     = optional(number, 10)   # Buffer incoming data to the specified size, in MBs, before delivering it to the s3 bucket.
    buffering_interval = optional(number, 1800) # Buffer incoming data for the specified period of time, in seconds, before delivering it to the s3 bucket.
    enable_cloudwatch  = optional(bool, false)
    compression_format = optional(string, "GZIP")
    kms_arn            = optional(string, null)
    processors = optional(map(list(object({
      parameter_name  = string
      parameter_value = string
    }))), null)
    # processors = {
    #   Lambda = [
    #     {
    #       parameter_name = "LambdaArn"
    #       parameter_value = "aws:lambda:xxx"
    #     }
    #   ]
    # }
  })
  default = null
}

variable "subscription_log_group_names" {
  type = list(string)
}

variable "kinesis_stream_name" {
  type    = string
  default = null
}

variable "s3_output_prefix" {
  type    = string
  default = null
}

variable "s3_error_output_prefix" {
  type    = string
  default = null
}

variable "enable_dynamic_partitioning" {
  type    = bool
  default = false
}

variable "subscription_filter_pattern" {
  type    = string
  default = ""
}
