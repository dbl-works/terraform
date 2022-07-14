variable "region" {
  type = string
}

variable "source_bucket_name" {
  type = string
}

variable "versioning" {
  default = true
  type    = bool
}

variable "kms_key_arn" {
  default = null
  type    = string
}
