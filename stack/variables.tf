variable "module_version" {
  type = string
  # TODO: should i make this a variable?
  default = "v2022.05.02"
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}
