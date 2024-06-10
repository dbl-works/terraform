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
    min_tls_version          = optional(string, "1.3") # 1.0, 1.1, 1.2, 1.3
    tls_1_3                  = string                  # "on/off"
    automatic_https_rewrites = string                  # "on/off"
    ssl                      = string                  # "strict"
    always_use_https         = string                  # "on/off"
  })
  default = null
}

# HSTS protects HTTPS web servers from downgrade attacks.
# These attacks redirect web browsers from an HTTPS web server to an attacker-controlled server, allowing bad actors to compromise user data and cookies.
# https://developers.cloudflare.com/ssl/edge-certificates/additional-options/http-strict-transport-security/
variable "hsts_settings" {
  type = object({
    enabled            = optional(bool, true)
    preload            = optional(bool, true)       # Initially disable until you are sure about your configuration
    max_age            = optional(number, 31536000) # Set it to least value for validating functionality.
    include_subdomains = optional(bool, true)
    nosniff            = optional(bool, true)
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
