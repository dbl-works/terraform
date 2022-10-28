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

variable "https_enabled" {
  type    = bool
  default = false
}

variable "alb_dns_name" {
  type = string
}

variable "s3_cloudflare_records" {
  # {
  #   cdn = {
  #     worker_script_name = "serve-cdn"
  #   },
  #   app = {
  #     worker_script_name = "serve-app"
  #   }
  # }
  type = map(object({
    worker_script_name = string
  }))
  default = {}
}
