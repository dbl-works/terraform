data "aws_region" "current" {}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "project" {
  type        = string
  description = "The project name"
}

variable "guest_account_id" {
  type        = string
  description = "The AWS account ID of the guest account"
}


locals {
  current_region = data.aws_region.current.name
  bucket_name    = "${var.project}-${var.environment}-${current_region}-shared-${guest_account_name}"
}
