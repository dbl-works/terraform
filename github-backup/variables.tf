variable "github_org" {
  type        = string
  description = "Slug of the Github Organization to backup"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Typically, there won't be any other environment for buckets."
}

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
  default     = 2048
  type        = number
  description = "Amount of memory in MB allocated to the Lambda"
}

variable "interval_value" {
  default     = 1
  type        = number
  description = "Interval value for the Cloudwatch Event"
  validation {
    condition     = var.interval_value > 0
    error_message = "Interval value must be greater than 0"
  }
}

# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rate-expressions.html
variable "interval_unit" {
  default     = "day"
  type        = string
  description = "Interval unit for the Cloudwatch Event"
  validation {
    condition     = contains(["minute", "minutes", "hour", "hours", "day", "days"], var.interval_unit)
    error_message = "Interval unit must be one of minute, minutes, hour, hours, day, days. If the value is equal to 1, then the unit must be singular. If the value is greater than 1, the unit must be plural"
  }
}
