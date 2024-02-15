variable "project" {}
variable "environment" {}

variable "create_kms_key" {
  type    = bool
  default = true
}

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
