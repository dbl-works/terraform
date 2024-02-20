variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "s3_bucket_name" {
  type        = string
  default     = null
  description = "default s3 bucket created to store the aws transfer family uploaded file"
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
  default = null
}

variable "users" {
  type = map(object({
    ssh_key        = string
    s3_prefix      = string
    s3_bucket_name = optional(string, null) # Must present if no default value provided for s3_bucket_name
    s3_kms_arn     = optional(string, null)
  }))
  description = "List of user who will use the aws transfer family servers"
  # Example:
  # {
  #   Harry = {
  #     ssh_key = "ssh-public-key-string"
  #     s3_prefix = "ssh-public-key-string"
  #     s3_bucket_name = "brussels"
  #     s3_kms_arn     = "arn::kms::xxxxxx"
  #   }
  # }
  default = {}
}

variable "home_directory_type" {
  type        = string
  description = "The type of landing directory (folder) you mapped for your users' home directory. Valid values are PATH and LOGICAL"
  default     = "PATH"
}
