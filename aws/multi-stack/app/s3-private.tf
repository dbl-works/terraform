locals {
  private_buckets_list = flatten([for settings in var.project_settings : settings.private_buckets_list])
  public_buckets_list  = flatten([for settings in var.project_settings : settings.public_buckets_list])
}

module "s3-private" {
  source = "../../s3-private"

  # This defines bucket_name as the key,
  # thus allows terraform to track the resources by bucket_name (the key)
  for_each = { for bucket_name in local.private_buckets_list : bucket_name => bucket_name }

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = each.key

  # Optional
  kms_deletion_window_in_days     = var.kms_deletion_window_in_days
  versioning                      = false
  primary_storage_class_retention = 0
  region                          = var.region
  regional                        = true
  s3_replicas                     = []
}
