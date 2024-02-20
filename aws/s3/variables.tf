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
