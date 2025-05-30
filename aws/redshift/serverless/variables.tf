variable "vpc_id" {}
variable "project" {}
variable "environment" {}
variable "subnet_ids" {}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "source_rds_arn" {
  type        = string
  description = "The identifier of the RDS instance to use as source for the Redshift Serverless workgroup"
}
