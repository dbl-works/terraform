variable "project" {}
variable "environment" {}
variable "domain_name" {}
variable "bucket_name_prefix" {
  default = "cdn"
}

locals {
  bucket_name = "${var.bucket_name_prefix}.${var.domain_name}"
}
