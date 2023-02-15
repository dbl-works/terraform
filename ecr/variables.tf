variable "project" {}

variable "mutable" { default = false }

variable "valid_days" {
  type    = number
  default = 3
}

variable "ecr_lifecycle_policy_rules" {
  type    = list(any)
  default = []
}
