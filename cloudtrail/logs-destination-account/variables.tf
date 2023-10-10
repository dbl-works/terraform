variable "organization_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "logging_account_ids" {
  type        = list(string)
  description = "The AWS Account ID(s) which produce the cloudtrail logs"
}
