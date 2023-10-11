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

variable "enable_management_cloudtrail" {
  type    = string
  default = true
}

variable "enable_data_cloudtrail" {
  type        = string
  default     = false
  description = "Data events can generate a large volume of logs, especially with frequently accessed resources like S3. Enable it only if you think it is essential to you."
}

variable "cloudtrail_s3_bucket_name" {
  type        = string
  description = "The name of the AWS S3 bucket for which CloudTrail will store the logs in"
}

variable "s3_bucket_arn_for_data_cloudtrail" {
  type        = list(string)
  default     = []
  description = "The ARN of the AWS S3 bucket for which CloudTrail data events (s3 bucket object deletion) will be captured."
}

variable "log_retention_days" {
  type    = number
  default = 14
}
