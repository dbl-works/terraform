variable "organization_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cloudtrail_roles" {
  type        = list(string)
  description = "Roles"
}

variable "logging_account_ids" {
  type        = list(string)
  description = ""
}
