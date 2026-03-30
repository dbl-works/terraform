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

variable "file_malwarescanning_enabled" {
  description = "Enable AWS GuardDuty Malware Protection for S3 on this bucket. Scans all newly uploaded objects for malware and tags them with scan results."
  type        = bool
  default     = false
}

variable "allow_downloading_unscanned_files" {
  description = "If true, only blocks downloads of files tagged as INFECTED. If false, blocks downloads of any file not explicitly tagged as CLEAN. Set to true initially when enabling scanning on existing buckets, then switch to false after backfilling scans."
  type        = bool
  default     = true
}
