variable "project" {}
variable "environment" {}
variable "application" {}
variable "rotate_automatically_after_days" { default = 90 }

variable "rotation_enabled" {
  type    = bool
  default = false
  description = "if enabled, will create a rotation and linked Lambda function."
}
