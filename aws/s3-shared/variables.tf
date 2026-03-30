variable "environment" {
  type        = string
  description = "The environment name"
}

variable "project" {
  type        = string
  description = "The project name"
}

variable "guest_account_name" {
  type        = string
  description = "The name of the guest account"
}

variable "region_name" {
  type        = string
  description = "The name of the region"
  default     = "eu-central-1"
}

locals {
  bucket_name = "${var.project}-${var.environment}-${var.region_name}-shared-${var.guest_account_name}"
}

variable "file_malwarescanning" {
  description = "Configuration for AWS GuardDuty Malware Protection for S3."
  type = object({
    enabled                           = bool
    allow_downloading_unscanned_files = bool
  })
  default = {
    enabled                           = true
    allow_downloading_unscanned_files = false
  }
}
