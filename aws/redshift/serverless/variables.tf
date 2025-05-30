data "aws_caller_identity" "current" {}

variable "vpc_id" {}
variable "project" {}
variable "environment" {}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet IDs to use for the Redshift Serverless workgroup"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "admin_password" {
  type        = string
  description = "The password for the admin user"
  sensitive   = true
}

variable "source_rds_arn" {
  type        = string
  description = "The identifier of the RDS instance to use as source for the Redshift Serverless workgroup"
}

variable "source_rds_security_group_id" {
  type        = string
  description = "The security group of the RDS instance to use as source for the Redshift Serverless workgroup"
}

variable "ecs_security_group_id" {
  type        = string
  description = "The security group of the ECS cluster to use as source for the Redshift Serverless workgroup"
}
