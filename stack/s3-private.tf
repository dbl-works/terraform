module "s3-storage" {
  source = "github.com/dbl-works/terraform//s3-private?ref=${var.module_version}"

  count = length(var.private_buckets_list)

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = var.private_buckets_list[count.index].bucket_name

  # Optional
  kms_deletion_window_in_days     = var.private_buckets_list[count.index].kms_deletion_window_in_days
  versioning                      = var.private_buckets_list[count.index].versioning
  primary_storage_class_retention = var.private_buckets_list[count.index].primary_storage_class_retention
}
