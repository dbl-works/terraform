module "s3-frontend" {
  source = "github.com/dbl-works/terraform//s3-public?ref=${var.module_version}"

  count = length(var.public_buckets_list)

  # Required
  environment = var.environment
  project     = var.project
  bucket_name = var.public_buckets_list[count.index].bucket_name

  # Optional
  versioning                      = var.public_buckets_list[count.index].versioning
  primary_storage_class_retention = var.public_buckets_list[count.index].primary_storage_class_retention
}
