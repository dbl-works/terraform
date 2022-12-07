variable "username" {
  type = string
}

variable "project_access" {
  type = map(any)
}

variable "region" {
  type = string
}

variable "allow_listing_ecs" {
  type    = bool
  default = true
}
