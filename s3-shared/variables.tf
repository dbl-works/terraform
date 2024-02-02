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

variable "guest_account_name" {
  type        = string
  description = "The name of the guest account"
}

locals {
  current_region = data.aws_region.current.name
  bucket_name    = "${var.project}-${var.environment}-${data.aws_region.current.name}-shared-${var.guest_account_name}"
}
