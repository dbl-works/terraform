variable "project" {}
variable "environment" {}
variable "domain_name" {}
variable "kms_deletion_window_in_days" { default = 30 }
variable "bucket_name" {
  default = "storage.${var.domain_name}"
}
