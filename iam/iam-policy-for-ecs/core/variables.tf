variable "username" {
  type = string
}

variable "region" {
  type = string
}

variable "projects" {
  default = []
  type = set(object({
    name        = string
    environment = string
    region      = string
  }))
}
