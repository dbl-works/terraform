variable "environment" {}
variable "project" {}
variable "vpc_id" {}

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

# CIDR blocks to allo traffic from
# Setting this will enable NLB traffic
variable "allowlisted_ssh_ips" {
  type = list(string)
  default = []
}

# This is where the load balancer will send health check requests to the app containers
# The default follows the methodology of Kubernetes, see: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request
# Find more about our own standard for health checks here: https://www.notion.so/tractioneng/Health-Checks-2555294b70ce4af4849e8d0fefeb16f8
variable "health_check_path" { default = "/healthz" }
