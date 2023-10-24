variable "organization_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_cloudtrail" {
  type    = bool
  default = false
}

variable "log_producer_account_ids" {
  type        = list(string)
  description = "The AWS Account IDs which will be sent the cloudtrail logs to the cloudtrail S3 bucket."
}
