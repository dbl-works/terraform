# Terraform Module: S3 Replica

A repository for setting up an S3 bucket replica

## Usage

```terraform
provider "aws" {
  alias  = "replica"
  region = 'ap-southeast-1'
}

# For private bucket
module "s3-replica-for-private-bucket" {
  source = "github.com/dbl-works/terraform//s3-replica?ref=v2021.07.05"
  providers = {
    aws.replica = "aws.replica"
  }

  region             = 'ap-southeast-1'
  environment        = "staging"
  project            = "someproject"
  source_bucket_name = "someproject-staging-storage"

  # Optional
  versioning                  = var.versioning
  kms_deletion_window_in_days = 30
  enable_encryption           = true
}

# For public bucket
module "s3-replica-for-public-bucket" {
  source = "../s3-replica"

  region             = var.region
  source_bucket_name = var.bucket_name
  versioning         = var.versioning

  depends_on = [
    aws_s3_bucket_versioning.main-bucket-versioning
  ]
}

module "s3_replica" {
  source = "../s3-replica"
  count = length(var.replica_regions)

  region             = var.replica_regions[count.index]
  source_bucket_name = var.bucket_name
  versioning         = var.versioning

  kms_deletion_window_in_days = var.kms_deletion_window_in_days
}

```
