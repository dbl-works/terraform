variable "cloudflare_email" {
  type      = string
  sensitive = true
}
variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

variable "domain" {
  type = string
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
}

variable "bastion_eip_id" {
  type = string
}

variable "nlb_dns_name" {
  type = string
}

variable "worker_script_name" {
  type = string
}

variable "s3_bucket_cdn_subdomain" {
  type = string
}
