variable "domain" {
  type = string
}

variable "bastion_public_dns" {
  type    = string
  default = null
}

variable "bastion_enabled" {
  type    = bool
  default = false
}

variable "alb_dns_name" {
  type = string
}

variable "cdn_worker_script_name" {
  type = string
}

variable "app_worker_script_name" {
  type = string
}
