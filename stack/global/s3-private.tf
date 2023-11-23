module "s3-storage" {
  source = "../../s3-private"

  # This defines bucket_name as the key,
  # thus allows terraform to track the resources by bucket_name (the key)
  for_each = { for bucket in var.private_buckets_list : bucket.bucket_name => bucket }

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = each.value.bucket_name

  # Optional
  kms_deletion_window_in_days     = each.value.kms_deletion_window_in_days
  versioning                      = each.value.versioning
  primary_storage_class_retention = each.value.primary_storage_class_retention
  region                          = each.value.region
  regional                        = true
  s3_replicas                     = each.value.replicas
}
