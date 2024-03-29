variable "regional" {
  type    = bool
  default = false
}

variable "region" {
  type        = string
  default     = null
  description = "Typically, we abbreviate the region for naming, e.g. 'us-east-1' is passed as 'us-east'."
}

variable "project" {
  type = string
}

variable "subnet_type" {
  type    = string
  default = "public"
  validation {
    condition     = contains(["public", "private"], var.subnet_type)
    error_message = "subnet_type must be either public or private"
  }
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "If not provided, the cluster name will be generated from the project and environment (and region if regional)."
}

variable "environment" {
  type = string
}

variable "ecs_fargate_log_mode" {
  type    = string
  default = "non-blocking"
}

variable "ephemeral_storage_size_in_gib" {
  type    = number
  default = 20 # 20 is the default of AWS Fargate

  validation {
    condition     = var.ephemeral_storage_size_in_gib == 20 || (var.ephemeral_storage_size_in_gib >= 21 && var.ephemeral_storage_size_in_gib <= 200)
    error_message = "ephemeral_storage_size_in_gib must omitted to default to 20, or set to be between 21 and 200 (GiB)"
  }
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "app_config" {
  type = object({
    name                  = optional(string, "web")
    image_tag             = optional(string, "latest-main")
    image_name            = optional(string, null)     #  Docker image name of the app container. Required if ecr_repo_name is null.
    secrets               = optional(list(string), []) # keys of secrets stored in the aws secrets manager required for the app
    ecr_repo_name         = optional(string, null)     # Required if image_name is null.
    container_ports       = optional(list(number), [])
    environment_variables = optional(map(string), {})
    commands = optional(list(string), [
      "bundle",
      "exec",
      "puma",
      "-C",
      "config/puma.rb"
    ])
    mount_points = optional(
      list(object({
        sourceVolume : string
        containerPath : string
      }))
    , null)
  })
}

variable "sidecar_config" {
  type = list(object({
    name           = optional(string, "logger")
    secrets        = optional(list(string), []) # keys of secrets stored in the aws secrets manager required for the sidecar
    image_tag      = optional(string, null)     # If it is null, it would be set as the app image tag
    image_name     = optional(string, null)     # Required if ecr_repo_name is null.
    ecr_repo_name  = optional(string, null)     # Required if image_name is null.
    container_port = optional(number, null)
    protocol       = optional(string, "tcp")
    mount_points = optional(
      list(object({
        sourceVolume : string
        containerPath : string
      }))
    , [])
  }))
  default = []
}

variable "service_discovery_namespace_id" {
  type        = string
  default     = null
  description = "required for service discovery"
}

locals {
  service_discovery_enabled = var.service_discovery_namespace_id != null
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "volume" {
  type = list(object({
    name = optional(string, true)
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string, "/")
      transit_encryption      = optional(string, "DISABLED") # Valid values are "ENABLED"/"DISABLED"
      transit_encryption_port = optional(number, null)
      access_point_id         = optional(string, null)
      iam                     = optional(string, null)
    }), null)
  }))
  default = []
}

variable "container_definitions_file_name" {
  type        = string
  default     = "web"
  description = "container definitions file name to be used."
}

variable "secrets_alias" {
  type    = string
  default = null
}

variable "load_balancer_target_group_name" {
  type    = string
  default = null
}

variable "with_load_balancer" {
  type    = bool
  default = true
}

variable "cloudwatch_logs_retention_in_days" {
  type    = number
  default = 7
}

variable "aws_lb_target_group_arn" {
  type    = string
  default = null
}

variable "ulimits" {
  type = list(object({
    name      = string
    softLimit = number
    hardLimit = number
  }))
  default = []

  validation {
    condition     = alltrue([for ulimit in var.ulimits : contains(["core", "cpu", "data", "fsize", "locks", "memlock", "msgqueue", "nice", "nofile", "nproc", "rss", "rtprio", "rttime", "sigpending", "stack"], ulimit.name)])
    error_message = "Each 'name' must be one of the specified values."
  }
}


variable "deployment_circuit_breaker" {
  type = object({
    enable   = optional(bool, true)
    rollback = optional(bool, true)
  })
  default = {
    enable   = true
    rollback = true
  }
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "availability_zones" {
  type     = list(string)
  default  = ["eu-central-1a", "eu-central-1b"]
  nullable = false
}
