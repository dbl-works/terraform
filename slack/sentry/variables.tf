variable "sentry_organization" {
  type = string
}

variable "slack_workspace_name" {
  type = string
}

variable "project" {
  type = string
}

variable "frequency" {
  type        = number
  description = "Perform actions at most once every X minutes for this issue. Defaults to 30."
  default     = 30
}
