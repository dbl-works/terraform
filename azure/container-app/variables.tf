variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "zone_redundancy_enabled" {
  type    = bool
  default = true
}

variable "internal_load_balancer_enabled" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "environment_variables" {
  # {
  #   SAMPLE_ENV = "xxx"
  # }
  type    = map(string)
  default = {}
}

# Secrets cannot be removed from the service once added,
# attempting to do so will result in an error.
# # # Their values may be zeroed, i.e. set to "", but the named secret must persist.
# This is due to a technical limitation on the service which causes the service to become unmanageable.
variable "secret_variables" {
  # [
  #   "SAMPLE_SECRET1"
  # ]
  type    = list(string)
  default = []
}

locals {
  env = merge(
    { for secret in var.secret_variables : secret => { secret_name = secret } },
    { for key, value in var.environment_variables : key => { value = value, secret_name = null } }
  )
}

variable "revision_mode" {
  type        = string
  description = "In Single mode, a single revision is in operation at any given time. In Multiple mode, more than one revision can be active at a time and can be configured with load distribution via the traffic_weight block in the ingress configuration."
  default     = "Multiple"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision mode must be either Single or Multiple"
  }
}

variable "min_replicas" {
  type     = number
  default  = 1
  nullable = false
}

variable "max_replicas" {
  type     = number
  default  = 2
  nullable = false
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  type    = string
  default = "0.5Gi"
}

variable "image_version" {
  type     = string
  default  = "latest"
  nullable = false
}

variable "target_port" {
  type     = number
  default  = 3000
  nullable = false
}

variable "exposed_port" {
  type     = number
  default  = 3000
  nullable = false
}

variable "transport" {
  type     = string
  default  = "tcp"
  nullable = false

  validation {
    condition     = contains(["auto", "http", "http2", "tcp"], var.transport)
    error_message = "Must be either auto, http, http2 or tcp"
  }
}

# https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
variable "health_check_options" {
  type = object({
    port                    = optional(string, 80)
    transport               = optional(string, "HTTP")
    failure_count_threshold = optional(number, 5)
    interval_seconds        = optional(number, 60) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
    path                    = optional(string, "/livez")
    timeout                 = optional(number, 5)
  })
  nullable = false
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "user_assigned_identity_name" {
  type = string
}

variable "container_registry_name" {
  type        = string
  default     = null
  description = "Defaults to 'project'"
}

variable "container_app_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'"
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
