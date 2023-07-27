variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "runtime" {
  type    = string
  default = "ruby3.2"
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 1024
}

variable "slack_webhook_url" {
  type = string
}

