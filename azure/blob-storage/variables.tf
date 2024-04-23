variable "resource_group_name" {
  type = string
}

variable "name" {
  type        = string
  description = "Blob name can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long"
}

variable "container_name" {
  type    = string
  default = null
}

variable "region" {
  type = string
}

variable "lifecycle_rules" {
  type = map(object({
    prefix_match                                               = list(string)
    blob_types                                                 = list(string)
    tier_to_cool_after_days_since_modification_greater_than    = optional(number, -1)
    tier_to_archive_after_days_since_modification_greater_than = optional(number, -1)
    delete_after_days_since_modification_greater_than          = optional(number, -1)
  }))
  default = {}
}

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

# BlobStorage: for storing unstructured object data, such as text or binary data
# BlockBlobStorage: premium performance storage account type designed specifically for storing block blobs and append blobs.
# FileStorage: built for high-performance file shares.
# Storage: Legacy, support blobs, files, queues, tables, and disks.
# StorageV2: Latest, support blobs, files, queues, tables, and disks
variable "account_kind" {
  type     = string
  default  = "StorageV2"
  nullable = false

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Must be either BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2"
  }
}

variable "account_tier" {
  type     = string
  default  = "Standard"
  nullable = false

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
  default  = "GZRS"
  nullable = false

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.account_replication_type)
    error_message = "Must be either LRS, ZRS, GRS, GZRS, RAGRS, or RAGZRS"
  }
}

variable "blob_properties_config" {
  type = object({
    versioning_enabled            = optional(bool, true)
    change_feed_enabled           = optional(bool, true)
    change_feed_retention_in_days = optional(number, 14)
    last_access_time_enabled      = optional(bool, true)
  })
  default = {}
}

variable "public_network_access_enabled" {
  type    = bool
  default = false

  nullable = false
}

variable "shared_access_key_enabled" {
  type    = bool
  default = false

  nullable = false
}

variable "allowed_ips" {
  type    = list(string)
  default = []

  nullable = false
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false

  nullable = false
}

variable "container_access_type" {
  type        = string
  default     = "private"
  nullable    = false
  description = "The Access Level configured for this Container."

  # Private: You cannot access a resource by using the resource URL. For example, if your blob's URL is https://account.blob.core.windows.net/container/blob.txt and if you try to access this resource in a browser, you will receive a 404 error even though the blob is present.
  # Blob: You can download a blob or get its properties by using the URL. However you will not be able to access a container's properties if the access level is set as Blob.
  # Public: It is similar to Blob public access level but if the ACL for a container is set as public, you can get a container's properties as well as list blobs in that container.
  validation {
    condition     = contains(["blob", "container", "private"], var.container_access_type)
    error_message = "Must be either blob, container or private"
  }
}

variable "static_website" {
  type = object({
    index_document     = string
    error_404_document = string
  })
  default = null
}

variable "versioning_enabled" {
  type     = bool
  default  = false
  nullable = false
}

variable "sas_policy" {
  type = object({
    expiration_period = optional(string, "00.02:00:00")
    expiration_action = optional(string, "Log")
  })
  default = null
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

variable "tags" {
  type    = map(string)
  default = null
}
