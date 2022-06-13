variable "project" {}
variable "environment" {}
variable "application" { default = "app" }
variable "kms_key_id" {
  type = string
}

variable "description" {
  type = string
}
