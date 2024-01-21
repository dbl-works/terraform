variable "services" {
  type = map(object({
    app_config = object({
      name                  = optional(string, "web")
      image_tag             = optional(string, "latest-main")
      image_name            = optional(string, null)     #  Docker image name of the app container. Required if ecr_repo_name is null.
      secrets               = optional(list(string), []) # keys of secrets stored in the aws secrets manager required for the app
      ecr_repo_name         = optional(string, null)     # Required if image_name is null.
      container_port        = optional(number, null)
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
    sidecar_config = optional(list(object({
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
    })), [])
    cpu                             = optional(number, 256)
    memory                          = optional(number, 512)
    desired_count                   = optional(number, 1)
    with_load_balancer              = optional(bool, true)
    ephemeral_storage_size_in_gib   = optional(number, 20)
    load_balancer_target_group_name = optional(string, null)
  }))
}

variable "environment" {
  type = string
}

variable "region" {
  type        = string
  default     = null
  description = "Typically, we abbreviate the region for naming, e.g. 'us-east-1' is passed as 'us-east'."
}

variable "regional" {
  type    = bool
  default = false
}

variable "project" {
  type = string
}
