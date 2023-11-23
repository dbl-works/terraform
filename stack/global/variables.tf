variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "global_accelerator_config" {
  type = object({
    load_balancers = list(object({
      region   = string
      endpoint = string
      weight   = optional(number, 128)
    }))
    client_affinity   = optional(string, "SOURCE_IP")
    health_check_path = optional(string, "/livez")
    health_check_port = optional(number, 3000)
  })
  default = null
}

variable "sentry_config" {
  type = map(object({
    organization_name    = string
    slack_workspace_name = string
    platform             = optional(string, "ruby-rails")
    sentry_teams         = optional(list(string), null)
    frequency            = optional(number, 30)
  }))
  default = {}
}
