# NOTE: the "master AWS account" refers to the management account that has the ability to manage certain aspects of all other accounts within the organization, including setting up organization-wide services like AWS CloudTrail for logging.
#       This is not necessarily the log-ingestor account, which likely should be its own account.

variable "environment" {
  type        = string
  description = "Specify the deployment environment, such as 'prod' for production or 'dev' for development. This is used for tagging resources."
}

variable "project" {
  type        = string
  description = "Specify the project name. This is used for tagging resources."
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = "Set this to 'true' to create an organizational trail that captures events across all accounts in the AWS Organization. Note: Organizational trails must be created in the master account of the AWS Organization."
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "Indicates if the CloudTrail should capture logs across all regions (true) or a single region (false)."
}

variable "enable_management_cloudtrail" {
  type        = string
  default     = true
  description = "Enables management events logging in CloudTrail, such as AWS Management Console actions."
}

variable "enable_data_cloudtrail" {
  type        = string
  default     = false
  description = "Toggle to enable logging of data events like S3 object-level operations; note that this can result in high log volume."
}

variable "cloudtrail_s3_bucket_name" {
  type        = string
  description = "Designates the S3 bucket name where CloudTrail logs are stored ('log-ingestor')."
}

variable "cloudtrail_s3_kms_arn" {
  type        = string
  description = "Provides the ARN of the KMS key for encrypting CloudTrail logs stored in the specified S3 bucket."
}

variable "s3_bucket_arn_for_data_cloudtrail" {
  type        = list(string)
  default     = []
  description = "Lists the S3 bucket ARNs for which data event logging (like object-level operations) is enabled in CloudTrail."
}

variable "log_retention_days" {
  type    = number
  default = 14
}
