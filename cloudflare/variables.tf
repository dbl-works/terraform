variable "domain" {
  type = string
}

variable "bastion_public_dns" {
  type    = string
  default = null
}

variable "nlb_dns_name" {
  type = string
}

variable "cdn_worker_script_name" {
  type = string
}

variable "s3_public_buckets" {
  type = list(object({
    name : string
    cdn_path : string
  }))
  default = []
}
