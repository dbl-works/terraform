variable "environment" {
  type        = string
  description = "The environment name"
}

variable "project" {
  type        = string
  description = "The project name"
}

variable "guest_account_name" {
  type        = string
  description = "The name of the guest account"
}

variable "region_name" {
  type        = string
  description = "The name of the region"
  default     = "eu-central-1"
}

locals {
  bucket_name = "${var.project}-${var.environment}-${var.region_name}-shared-${var.guest_account_name}"
}
