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

variable "certificate_resource_record_name" {
  type = string
}

variable "certificate_resource_record_type" {
  type        = string
  description = "Record type such as CNAME, A, MX etc"
}

variable "certificate_resource_record_value" {
  type = string
}
