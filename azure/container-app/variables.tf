variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
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

variable "user_assigned_identity_ids" {
  type = list(string)
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

# https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
variable "health_check_options" {
  type = object({
    port                    = optional(string, 80)
    transport               = optional(string, "HTTP")
    failure_count_threshold = optional(number, 5)
    interval_seconds        = optional(number, 7) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
    path                    = optional(string, "/livez")
    timeout                 = optional(number, 5)
  })
  nullable = false
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "container_app_environment_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'"
}

variable "key_vault_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'"
}

variable "user_assigned_identity_name" {
  type        = string
  default     = null
  description = "Defaults to 'project-environment'"
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
