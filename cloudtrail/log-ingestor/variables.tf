variable "project" {
  type        = string
  description = "value of the project tag"
}

variable "environment" {
  type        = string
  description = "value of the environment tag"
}

variable "enable_cloudtrail" {
  type    = bool
  default = false
}

variable "log_producer_account_ids" {
  type        = list(string)
  description = "The AWS Account IDs which will be sent the cloudtrail logs to the cloudtrail S3 bucket."
}
