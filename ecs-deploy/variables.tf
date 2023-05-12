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
    container_port        = optional(number, 3000)
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
  type = object({
    name           = optional(string, "logger")
    secrets        = optional(list(string), []) # keys of secrets stored in the aws secrets manager required for the sidecar
    image_tag      = optional(string, null)     # If it is null, it would be set as the app image tag
    image_name     = optional(string, null)     # Required if ecr_repo_name is null.
    ecr_repo_name  = optional(string, null)     # Required if image_name is null.
    container_port = optional(number, 4318)
    protocol       = optional(string, "tcp")
    mount_points = optional(
      list(object({
        sourceVolume : string
        containerPath : string
      }))
    , null)
  })
  default = null
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "volume_name" {
  type    = string
  default = null
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
