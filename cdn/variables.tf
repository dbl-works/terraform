variable "project" {}
variable "environment" {}
variable "domain_name" {}

variable "index_document" {
  default = "index.html"
}

variable "error_document" {
  default = "404.html"
}

variable "single_page_application" {
  type    = bool
  default = false
}

variable "routing_rules" {
  type    = string
  default = ""
}
