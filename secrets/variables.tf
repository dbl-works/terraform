variable "project" {}
variable "environment" {}

variable "create_kms_key" {
  type    = bool
  default = true
}
# TODO: @sam, add condition, either one need to be true or with value

variable "kms_key_id" {
  type    = string
  default = null
}

variable "application" {
  type    = string
  default = "app"
}

variable "description" {
  type    = string
  default = null
}
