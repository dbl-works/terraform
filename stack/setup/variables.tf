variable "kms_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "domain" {
  type = string
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "add_wildcard_subdomains" {
  type    = bool
  default = true
}
