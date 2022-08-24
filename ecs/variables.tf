variable "environment" {}
variable "project" {}
variable "vpc_id" {}

# A custom name overrides the default {project}-{environment} convention
variable "name" {
  type        = string
  description = "Custom name for the cluster. Must be unique per account if deploying to multiple regions."
  default     = null
}

# Regional allows clusters with the same name to be in multiple regions
variable "region" {
  type    = string
  default = "eu-central-1"
}
variable "regional" {
  default = false
  type    = bool
}

variable "allow_internal_traffic_to_ports" {
  type    = list(string)
  default = []
}

# Private IPs are where the app containers run
variable "subnet_private_ids" { type = list(string) }

# Public subnets are where forwarders run, such as a bastion, NAT or proxy
variable "subnet_public_ids" { type = list(string) }

# Allow containers to access the following resources from inside the cluster
variable "secrets_arns" { type = list(string) }
variable "kms_key_arns" { type = list(string) }

# Sets the certficate for https traffic into the cluster
# If not passed, no SSL endpoint will be setup
variable "certificate_arn" {}

# CIDR blocks to allow traffic from
# Setting this will enable NLB traffic
variable "allowlisted_ssh_ips" {
  type    = list(string)
  default = []
}

# This is where the load balancer will send health check requests to the app containers
variable "health_check_path" { default = "/healthz" }

variable "grant_read_access_to_s3_arns" {
  default = []
}

variable "grant_write_access_to_s3_arns" {
  default = []
}

variable "grant_read_access_to_sqs_arns" {
  default = []
}

variable "grant_write_access_to_sqs_arns" {
  default = []
}

variable "custom_policies" {
  default = []
}

variable "enable_dashboard" {
  type    = bool
  default = true
}

variable "enable_xray" {
  type    = bool
  default = false
}
