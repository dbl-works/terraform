variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_prefix" {
  type    = string
  default = null
}

variable "identity_provider_type " {
  type    = string
  default = "SERVICE_MANAGED"
}

variable "domain " {
  type    = string
  default = "S3"
}

variable "protocols " {
  type        = list(string)
  description = "Available protocols: AS2, SFTP, FTPS, FTP"
  default     = []
}

variable "endpoint_type " {
  type        = string
  description = "Available endpoints type: VPC, PUBLIC"
  default     = "PUBLIC"
}

variable "endpoint_details " {
  type        = string
  description = "Available endpoints type: VPC, PUBLIC"
  default     = "PUBLIC"
}

variable "users " {
  type        = map(string)
  description = "List of user names who will use the aws transfer family servers"
  # Example:
  # {
  #   Harry = {
  #     ssh_key = "ssh-public-key-string"
  #   }
  # }
  default = {}
}
