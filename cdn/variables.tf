variable "project" {}
variable "environment" {}
variable "domain_name" {}
variable "certificate_arn" {}

variable "price_class" {
  default = "PriceClass_100"
}

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
