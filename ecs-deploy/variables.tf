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

# variable "app_image_tag" {
#   type    = string
#   default = "latest-main"
# }

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
    log_group_name = optional(string, null) # would be set as /ecs/${var.project}-${var.environment} if null
    mount_points = optional(
      list(object({
        sourceVolume : string
        containerPath : string
      }))
    , null)
  })
  default = null
}

# variable "with_logger" {
#   type    = bool
#   default = true
# }

# variable "logger_secrets" {
#   type        = list(string)
#   default     = []
#   description = "keys of secrets stored in the aws secrets manager required for the logger"
# }

# variable "logger_mount_points" {
#   type = list(object({
#     sourceVolume : string
#     containerPath : string
#   }))
#   default = null
# }

# variable "logger_log_group_name" {
#   type    = string
#   default = null
# }

# variable "logger_protocol" {
#   type    = string
#   default = "tcp"
# }

# variable "logger_name" {
#   type    = string
#   default = "logger"
# }

# variable "logger_ecr_repo_name" {
#   type        = string
#   default     = null
#   description = "Required if logger_image_name is null."
# }

# variable "logger_container_port" {
#   type    = string
#   default = 4318
# }


# variable "logger_image_tag" {
#   type    = string
#   default = null
# }

# variable "app_image_name" {
#   type        = string
#   default     = null
#   description = "Docker image name of the app container. Required if ecr_repo_name is null."
# }

# variable "logger_image_name" {
#   type        = string
#   default     = null
#   description = "Required if logger_ecr_repo_name is null."
# }

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

# # TODO: Refactor all the variables relevant to apps and logs to one variables
# variable "ecr_repo_name" {
#   type        = string
#   default     = null
#   description = "Required if app_image_name is null."
# }

# variable "container_name" {
#   type    = string
#   default = "web"
# }

variable "volume_name" {
  type    = string
  default = null
}

variable "container_definitions_file_name" {
  type        = string
  default     = "web"
  description = "container definitions file name to be used."
}

# variable "app_container_port" {
#   type    = number
#   default = 3000
# }

# variable "log_path" {
#   type        = string
#   default     = "log"
#   description = "path in the apps which store the log"
# }

# variable "environment_variables" {
#   type    = map(string)
#   default = {}
# }

# variable "secrets" {
#   type        = list(string)
#   default     = []
#   description = "keys of secrets stored in the aws secrets manager required for the app"
# }

# variable "commands" {
#   type = list(string)
#   default = [
#     "bundle",
#     "exec",
#     "puma",
#     "-C",
#     "config/puma.rb"
#   ]
# }

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
