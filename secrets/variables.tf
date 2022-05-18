variable "project" {}
variable "environment" {}
variable "application" { default = "app" }

variable "secretsmanager_description" {
  type = string
}
