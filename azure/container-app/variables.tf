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

variable "revision_mode" {
  type        = string
  description = "In Single mode, a single revision is in operation at any given time. In Multiple mode, more than one revision can be active at a time and can be configured with load distribution via the traffic_weight block in the ingress configuration."
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision mode must be either Single or Multiple"
  }
}

variable "user_assigned_identity_name" {
  type = string
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  type    = string
  default = "0.5Gi"
}

variable "target_port" {
  type    = number
  default = 3000
}

# https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template
variable "health_check_options" {
  type = object({
    port                    = optional(string, 80)
    transport               = optional(string, "HTTP")
    failure_count_threshold = optional(number, 5)
    interval_seconds        = optional(number, 5) # How often, in seconds, the probe should run. Possible values are between 1 and 240. Defaults to 10
    path                    = optional(string, "/livez")
    timeout                 = optional(number, 5)
  })

}

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
