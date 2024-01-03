variable "environment" {
  type = string
}

variable "project_settings" {
  type = map(object({
    domain = string
  }))
}

variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}

variable "alternative_domains" {
  default = []
  type    = list(string)
}

variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}
