variable "project" {}
variable "environment" {}
variable "domain_name" {}
variable "kms_deletion_window_in_days" { default = 30 }
variable "bucket_name" {
  default = "storage"
}

locals {
  bucket_name = "${var.bucket_name_prefix}.${var.domain_name}"
}
