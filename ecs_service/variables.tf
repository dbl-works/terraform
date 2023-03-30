variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest-main"
}

variable "app_image_name" {
  type        = string
  default     = null
  description = "Docker image name of the app container. Required if ecr_repo_name is null."
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "ecr_repo_name" {
  type        = string
  default     = null
  description = "Required if app_image_name is null."
}

variable "container_name" {
  type    = string
  default = "web"
}

variable "volume_name" {
  type    = string
  default = "log"
}

variable "service_json_file_name" {
  type        = string
  default     = "web"
  description = "service json file name to be used."
}

variable "logger_ecr_repo_name" {
  type        = string
  default     = null
  description = "Required if logger_image_name is null."
}

variable "logger_container_port" {
  type    = string
  default = 4318
}

variable "logger_image_name" {
  type        = string
  default     = null
  description = "Required if logger_ecr_repo_name is null."
}

variable "app_container_port" {
  type    = number
  default = 3000
}

variable "log_path" {
  type        = string
  default     = "log"
  description = "path in the apps which store the log"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type        = list(string)
  default     = []
  description = "secrets key which is stored in the aws secret"
}

variable "commands" {
  type = list(string)
  default = [
    "bundle",
    "exec",
    "puma",
    "-C",
    "config/puma.rb"
  ]
}

variable "secrets_alias" {
  type    = string
  default = null
}

variable "load_balancer_target_group_name" {
  type    = string
  default = null
}

variable "with_logger" {
  type    = bool
  default = true
}
