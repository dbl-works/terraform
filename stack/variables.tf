variable "module_version" {
  type = string
  # TODO: should i make this a variable?
  default = "v2022.05.02"
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "account_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "private_buckets_list" {
  type = set(object({
    bucket_name                     = string
    versioning                      = bool
    primary_storage_class_retention = number
    kms_deletion_window_in_days     = number
  }))
}

variable "public_buckets_list" {
  type = set(object({
    bucket_name                     = string
    versioning                      = bool
    primary_storage_class_retention = number
  }))
}
