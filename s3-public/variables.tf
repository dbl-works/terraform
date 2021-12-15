variable "project" {}
variable "environment" {}
variable "domain_name" {}
variable "bucket_name" {
  default = "cdn.${var.domain_name}"
}
