variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "load_balancers" {
  type = list(object({
    region   = string
    endpoint = string
  }))
}

#
# optional variables
#
variable "client_affinity" {
  type    = string
  default = "SOURCE_IP"
}

variable "health_check_path" {
  type    = string
  default = "/livez"
}

variable "health_check_port" {
  type    = number
  default = 3000
}
