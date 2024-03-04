variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "lifecycle_rules" {
  type = object({
    name                                                       = string
    prefix_match                                               = list(string)
    blob_types                                                 = list(string)
    tier_to_cool_after_days_since_modification_greater_than    = optional(number, -1)
    tier_to_archive_after_days_since_modification_greater_than = optional(number, -1)
    delete_after_days_since_modification_greater_than          = optional(number, -1)
  })
}

variable "user_assigned_identity_ids" {
  type = list(string)
}

# BlobStorage: for storing unstructured object data, such as text or binary data
# BlockBlobStorage: premium performance storage account type designed specifically for storing block blobs and append blobs.
# FileStorage: built for high-performance file shares.
# Storage: Legacy, support blobs, files, queues, tables, and disks.
# StorageV2: Latest, support blobs, files, queues, tables, and disks
variable "account_kind" {
  type    = string
  default = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Must be either BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2"
  }
}

variable "account_tier" {
  type    = string
  default = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Must be either Standard or Premium"
  }
}

# https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
variable "account_replication_type" {
  type = string
  # LRS: Least expensive. copies your data synchronously three times within a single physical location in the primary region
  # ZRS: copies your data synchronously across three Azure AZs in the primary region.
  # # Secondary Region
  # GRS: LRS (Primary Region) + LRS in secondary region.
  # GZRS: ZRS (Primary Region) + LRS in secondary region
  default = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.account_replication_type)
    error_message = "Must be either LRS, ZRS, GRS, GZRS, RAGRS, or RAGZRS"
  }
}

variable "public_network_access_enabled" {
  type    = bool
  default = false

  nullable = false
}

variable "static_website" {
  type = object({
    index_document     = string
    error_404_document = string
  })
  default = {}
}

variable "versioning_enabled" {
  type    = bool
  default = false
}

variable "cors_config" {
  type = object({
    allowed_headers    = optional(list(string), ["*"])
    allowed_methods    = optional(list(string), ["POST", "PUT"])
    allowed_origins    = optional(list(string), ["*"])
    exposed_headers    = optional(list(string), ["ETag"])
    max_age_in_seconds = optional(number, 60)
  })

  default = {}
}

locals {
  name = "${var.project}-${var.environment}"
  default_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
