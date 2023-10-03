variable "environment" {
  type = string
}

variable "organization_name" {
  type = string
}

variable "is_organization_trail" {
  type    = bool
  default = false
}

variable "is_multi_region_trail" {
  type    = bool
  default = true
}

variable "logging_account_id" {
  type = string
}

variable "target_id" {
  type        = string
  description = "The unique identifier (ID) of the root, organizational unit, or account number that you want to attach the policy to."
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
