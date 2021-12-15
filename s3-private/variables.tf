variable "project" {}
variable "environment" {}
variable "bucket_name" {}
variable "kms_deletion_window_in_days" {
  default     = 30
  type        = number
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. If the KMS key is a multi-Region primary key with replicas, the waiting period begins when the last of its replica keys is deleted. Otherwise, the waiting period begins immediately."
}

# If versioning is enabled then a history of all object changes and deletions is retained.
variable "versioning" {
  default = true
  type    = bool
}

# How many days objects should remain in the primary storage class before being transitions
# Setting to 0 will disable class transition and all data will stay in the primary storage class
variable "primary_storage_class_retention" {
  default     = 0
  type        = number
  description = "Number of days before objects stay in the primary storage class"
}
