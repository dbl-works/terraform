module "s3-replica" {
  count = length(var.replica_regions)

  source = "../s3-replica"

  region             = var.replica_regions[count.index]
  source_bucket_name = var.bucket_name
  versioning         = var.versioning

  depends_on = [
    aws_s3_bucket_versioning.main-bucket-versioning
  ]
}
