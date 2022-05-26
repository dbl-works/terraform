variable "domain" {
  type = string
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "bastion_public_dns" {
  type = string
}

variable "nlb_dns_name" {
  type = string
}

variable "cdn_worker_script_name" {
  type = string
}

variable "s3_cdn_buckets" {
  type = map(object({
    cdn_path : string
  }))
  default = {}
}
