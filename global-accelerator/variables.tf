variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "client_affinity" {
  type    = string
  default = "SOURCE_IP"
}

variable "health_check_path" {
  type    = string
  default = "/livez"
}

variable "client_affinity" {
  type    = number
  default = 3000
}

variable "load_balancers" {
  type = list(object({
    region   = string
    endpoint = string
  }))
}
