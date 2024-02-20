variable "alias" {} # will be stored as alias/{project}/{environment}/{alias}
variable "environment" {}
variable "description" {}
variable "project" {}
variable "multi_region" {
  type    = bool
  default = false
}

variable "deletion_window_in_days" { default = 30 }
