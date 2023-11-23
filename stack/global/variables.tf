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
