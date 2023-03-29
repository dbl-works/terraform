variable "project" {}
variable "environment" {}
variable "bucket_name" {
  default = null
  type    = string
}
variable "kms_deletion_window_in_days" {
  default     = 30
  type        = number
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. If the KMS key is a multi-Region primary key with replicas, the waiting period begins when the last of its replica keys is deleted. Otherwise, the waiting period begins immediately."
}

variable "policy_allow_listing_all_buckets" {
  default = true
  type    = bool
}

# If versioning is enabled then a history of all object changes and deletions is retained.
variable "versioning" {
  default = true
  type    = bool
}

variable "regional" {
  default = false
  type    = bool
}

variable "region" {
  default = null
  type    = string
}

variable "multi_region_kms_key" {
  default = false
  type    = bool
}

# How many days objects should remain in the primary storage class before being transitions
# Setting to 0 will disable class transition and all data will stay in the primary storage class
variable "primary_storage_class_retention" {
  default     = 0
  type        = number
  description = "Number of days before objects stay in the primary storage class"
}

variable "s3_replicas" {
  # eg. [
  #   {
  #     bucket_arn = "arn-1"
  #     kms_arn = "kms-1"
  #     region = "ap-southeast-1"
  #   }
  # ]
  default = []
  type = list(object({
    bucket_arn = string
    kms_arn    = string
    region     = string
  }))
}

# The headers which are allowed to be used for direct browser uploads.
variable "cors_allowed_headers" {
  type    = list(string)
  default = ["*"]
}

# The methods which are allowed to be used for direct browser uploads.
variable "cors_allowed_methods" {
  type    = list(string)
  default = ["POST", "PUT"]
}

# The origins which are allowed to be used for direct browser uploads.
# The default is all origins which is not recommended for production.
variable "cors_allowed_origins" {
  type    = list(string)
  default = ["*"]
}

# The headers to expose when making requests from the browser.
variable "cors_expose_headers" {
  type    = list(string)
  default = ["ETag"]
}
