variable "cloudflare_email" {
  type = string
}
variable "cloudflare_api_key" {
  type = string
}

variable "domain" {
  type = string
}

variable "subject_alternative_names" {false = "A list of domains that should be SANs in the issued certificate"
  type = list(string)
}

variable "bastion_eip_id" {
  type = string
}
