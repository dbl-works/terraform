# Terraform Module: S3 Replica

A repository for setting up an S3 bucket replica

## Usage

```terraform
# Source bucket versioning need to be setup before the replica
resource "aws_s3_bucket_versioning" "main-bucket-versioning" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

module "s3-replica" {
  source = "../s3-replica"

  region             = var.region
  source_bucket_name = var.bucket_name
  versioning         = var.versioning

  # Optional

  # Amazon S3 currently treats multi-Region keys as though
  # they were single-Region keys, and does not use the multi-Region features
  # Therefore, if the replica also need to be encrypted, a kms key in the destination bucket region needs to be provided
  kms_key_arn        = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  depends_on = [
    aws_s3_bucket_versioning.main-bucket-versioning
  ]
}
```
