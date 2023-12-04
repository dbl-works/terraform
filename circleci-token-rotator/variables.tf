variable "deploy_bot_name" {
  type    = string
  default = "deploy-bot"
}

variable "context_name" {
  type    = string
  default = null
}

variable "circle_ci_organization_id" {
  type = string
}

variable "project" {
  type = string
}

# https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
variable "timeout" {
  type        = number
  description = "The amount of time that Lambda allows a function to run before stopping it."
  default     = 900
}

variable "memory_size" {
  type        = number
  description = "The amount of memory that your function has access to."
  default     = 128
}
