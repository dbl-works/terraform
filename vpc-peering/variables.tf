variable "project" {
  type = string
}

variable "environment" {
  type = string
}

# requester
variable "requester_region" {
  type = string
}

variable "requester_vpc_id" {
  type = string
}

# accepter
variable "accepter_region" {
  type = string
}

variable "accepter_vpc_id" {
  type = string
}

variable "cross_region_kms_keys_arns" {
  type    = list(string)
  default = []
}
