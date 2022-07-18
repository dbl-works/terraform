variable "project" {}
variable "environment" {}
variable "bucket_name" {}

# If versioning is enabled then a history of all object changes and deletions is retained.
variable "versioning" {
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
  # eg. {
  #   bucket-1 = {
  #     bucket_arn = "arn-1"
  #   }
  # }
  default = {}
  type    = map(object({
    bucket_arn = string,
  }))
}
