variable "region" {
  type        = string
  description = "The AWS region where resources are deployed"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., staging, production)"
}

variable "project_name" {
  type        = string
  description = "The project name for specific project access"
  default     = null
}

variable "project_tag" {
  type        = string
  description = "The principal tag key for project-based access"
  default     = "staging-developer-access-projects"
}
