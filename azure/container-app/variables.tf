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

variable "repository_name" {
  type    = string
  default = null
}

variable "subnet_id" {
  type = string
}

variable "zone_redundancy_enabled" {
  type     = bool
  default  = true
  nullable = false
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
    { for secret in var.secret_variables : replace(secret, "-", "_") => { secret_name = secret, value = null } },
    { for key, value in var.environment_variables : key => { value = value, secret_name = null } }
  )
}

variable "revision_mode" {
  type        = string
  description = "In Single mode, a single revision is in operation at any given time. In Multiple mode, more than one revision can be active at a time and can be configured with load distribution via the traffic_weight block in the ingress configuration."
  default     = "Single"

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

variable "image_version" {
  type     = string
  default  = "latest"
  nullable = false
}

variable "target_port" {
  type    = number
  default = null
}

variable "exposed_port" {
  type    = number
  default = null
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
    port                    = optional(string, null)
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

variable "key_vault_name" {
  type    = string
  default = null
  # TODO: Required if secret variables present
}

variable "user_assigned_identity_name" {
  type = string
}

variable "container_registry_login_server" {
  type    = string
  default = null
}

variable "container_apps" {
  type = map(object({
    command = list(string) # "A command to pass to the container to override the default. This is provided as a list of command line elements without spaces."
    cpu     = optional(number, 0.25)
    memory  = optional(string, "0.5Gi")
  }))
}

variable "container_app_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'"
}

# Logging
# The Free SKU has a default daily_quota_gb value of 0.5 (GB).
variable "logging_sku" {
  type = string
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.logging_sku)
    error_message = "Must be either Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018"
  }
  default = "PerGB2018"
}


variable "custom_domain" {
  type = object({
    certificate_binding_type = optional(string, "SniEnabled")
    certificate_id           = string
    domain_name              = string
  })

  default = null
}

variable "logs_retention_in_days" {
  type     = number
  nullable = false
  default  = 90
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'."
}

locals {
  default_name = "${var.project}-${var.environment}"

  default_app_port = 3000

  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
