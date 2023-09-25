variable "project" {}
variable "environment" {}

variable "ruby_major_version" {
  default     = "2"
  type        = string
  description = "Ruby 3 requires Terraform 5.0+"
}

variable "timeout" {
  default     = 900
  type        = number
  description = "Maximum amount of time for the Lambda to run in seconds"
}

variable "memory_size" {
  default     = 512
  type        = number
  description = "Amount of memory in MB allocated to the Lambda"
}

variable "github_org" {
  type        = string
  description = "Slug of the Github Organization to backup"
}
