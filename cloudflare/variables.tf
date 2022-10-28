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

variable "tls_settings" {
  type = object({
    tls_1_3                  = string # "on/off"
    automatic_https_rewrites = string # "on/off"
    ssl                      = string # "strict"
    always_use_https         = string # "on/off"
  })
  default = null
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
