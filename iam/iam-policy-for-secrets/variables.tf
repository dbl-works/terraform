variable "environment" {
  type = string
}

variable "project_access" {
  type = map(any)
  default = []
}

variable "region" {
  type = string
}
