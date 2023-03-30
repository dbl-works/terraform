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

variable "image_tag" {
  type    = string
  default = "latest-main"
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
  type = string
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
  default     = "web_with_logger"
  description = "service json file name to be used. Options: web_with_logger"
}

variable "logger_ecr_repo_name" {
  type = string
}

variable "logger_container_port" {
  type    = string
  default = 4318
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
