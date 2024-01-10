module "s3-frontend" {
  source = "../../s3-public"

  # This defines bucket_name as the key,
  # thus allows terraform to track the resources by bucket_name (the key)
  for_each = { for bucket_name in local.public_buckets_list : bucket_name => bucket_name }

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = each.key

  # Optional
  versioning                      = false
  primary_storage_class_retention = 0
  s3_replicas                     = []
}
