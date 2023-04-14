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

variable "identity_provider_type" {
  type    = string
  default = "SERVICE_MANAGED"
}

variable "server_domain" {
  type        = string
  description = "The domain of the storage system that is used for file transfers. Valid values are: S3 and EFS."
  default     = "S3"
}

variable "protocols" {
  type        = list(string)
  description = "Available protocols: AS2, SFTP, FTPS, FTP"
  default     = ["SFTP"]
}

variable "endpoint_type" {
  type        = string
  description = "Available endpoints type: VPC, PUBLIC"
  default     = "PUBLIC"
}

variable "endpoint_details" {
  type = object({
    address_allocation_ids = list(string)
    subnet_ids             = list(string)
    vpc_id                 = string
  })
  # Example:
  # {
  #   Harry = {
  #     ssh_key = "ssh-public-key-string"
  #   }
  # }
  default = null
}

variable "users" {
  type        = map(object({ ssh_key = string }))
  description = "List of user names who will use the aws transfer family servers"
  # Example:
  # {
  #   Harry = {
  #     ssh_key = "ssh-public-key-string"
  #   }
  # }
  default = {}
}
