variable "environment" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "Whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account."
}

variable "is_multi_region_trail" {
  type    = bool
  default = true
}

variable "logging_account_id" {
  type        = string
  description = "The AWS Account which will store the log."
}

variable "enable_management_cloudtrail" {
  type    = string
  default = true
}

variable "enable_data_cloudtrail" {
  type        = string
  default     = false
  description = "Data events can generate a large volume of logs, especially with frequently accessed resources like S3. Enable it only if you think it is essential to you."
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "destination_s3_arn" {
  type = string
}
