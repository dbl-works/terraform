variable "project" {}

variable "mutable" { default = false }

variable "valid_days" {
  type    = number
  default = 3
}

variable "protected_tags" {
  type        = list(string)
  default     = []
  description = "Image with this tag will be kept at least one"
}

variable "ecr_lifecycle_policy_rules" {
  type    = list(any)
  default = []
}
