variable "sentry_organization" {
  type = string
}

variable "slack_workspace_name" {
  type = string
}

variable "project" {
  type = string
}

variable "platform" {
  type    = string
  default = "rails"
}

variable "sentry_team" {
  type        = list(string)
  description = " The slugs of the teams to create the project for."
  default     = null
}

variable "resolve_age" {
  type        = number
  description = "Hours in which an issue is automatically resolve if not seen after this amount of time."
  default     = 720
}

variable "frequency" {
  type        = number
  description = "Perform actions at most once every X minutes for this issue. Defaults to 30."
  default     = 30
}

variable "sentry_project_slug" {
  type        = string
  default     = null
  description = "The slug of the project to create the issue alert for."
}

variable "sentry_project_name" {
  type    = string
  default = null
}
