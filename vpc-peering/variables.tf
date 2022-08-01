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

variable "requester_cidr_block" {
  type = string
}

# accepter
variable "accepter_region" {
  type = string
}

variable "accepter_vpc_id" {
  type = string
}

variable "accepter_cidr_block" {
  type = string
}
