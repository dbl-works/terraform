variable "project" {
  type = string
}

variable "environment" {
  type = string
}
variable "bucket_name" {
  type = string
}

variable "versioning" {
  default = true
  type    = bool
}

variable "enable_encryption" {
  default = false
  type    = bool
}

variable "kms_deletion_window_in_days" {
  default = 30
  type    = number
}

variable "multi_region_kms_key" {
  default = false
  type    = bool
}

variable "writers" {
  type = list(object({
    policy_id = string
    prefix    = string
  }))
  default = []
}

variable "file_malwarescanning" {
  description = "Configuration for AWS GuardDuty Malware Protection for S3."
  type = object({
    enabled                           = bool
    allow_downloading_unscanned_files = bool
  })
  default = {
    enabled                           = false
    allow_downloading_unscanned_files = true
  }
}
