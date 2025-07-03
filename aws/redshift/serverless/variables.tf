data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = "${var.project}/infra/${var.environment}"
}

locals {
  name             = "${var.project}-${var.environment}"
  infra_credentials = jsondecode(data.aws_secretsmanager_secret_version.infra.secret_string)
}

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
