variable "project" {
  type = string
}

variable "slack_webhook_url" {
  type = string
  validation {
    condition     = can(regex("^https://", var.slack_webhook_url))
    error_message = "The URL must start with https"
  }
}

variable "slack_channel" {
  type = string
}
