variable "project" {}
variable "environment" {}
variable "bucket_name" {}

# If versioning is enabled then a history of all object changes and deletions is retained.
variable "versioning" {
  default = false
  type = "boolean"
}
