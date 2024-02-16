variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "commands" {
  type = list(string)
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "image_name" {
  type    = string
  default = null
}

variable "ecr_repo_name" {
  type    = string
  default = null
}

variable "image_tag" {
  type = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "aws_iam_role_name" {
  type    = string
  default = null
}

variable "secret_name" {
  type    = string
  default = null
}

variable "secrets" {
  type    = list(string)
  default = []
}

variable "ecs_fargate_log_mode" {
  type    = string
  default = "non-blocking"
}

variable "enable_cloudwatch_log" {
  type    = bool
  default = false
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 14
}
