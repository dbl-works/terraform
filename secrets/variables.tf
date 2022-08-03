variable "project" {}
variable "environment" {}

variable "kms_key_id" {
  type = string
}

variable "application" {
  type    = string
  default = "app"
}

variable "description" {
  type    = string
  default = null
}
