variable "services" {
  type = map(object({
    app_config  = map(string)
    environment = string
    project     = string
  }))
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}
