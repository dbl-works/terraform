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

variable "image_name" {
  type = string
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

variable "secrets_alias" {
  type    = string
  default = null
}

variable "secrets" {
  type    = list(string)
  default = []
}
