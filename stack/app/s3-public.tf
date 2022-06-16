module "s3-frontend" {
  source = "../../s3-public"

  # This defines bucket_name as the key,
  # thus allows terraform to track the resources by bucket_name (the key)
  for_each = { for bucket in var.public_buckets_list : bucket.bucket_name => bucket }

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = each.value.bucket_name

  # Optional
  versioning                      = each.value.versioning
  primary_storage_class_retention = each.value.primary_storage_class_retention
}
