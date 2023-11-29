variable "availability_zones" {
  type = list(string)
}
variable "environment" {}
variable "project" {}
variable "cidr_block" { default = "10.0.0.0/16" }
