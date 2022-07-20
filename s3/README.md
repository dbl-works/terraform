# Terraform Module: S3

A repository for setting up an S3 bucket

## Usage

```terraform
# For private bucket
module "s3-private" {
  source = "github.com/dbl-works/terraform//s3-private?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-storage"

  # Optional
  kms_deletion_window_in_days     = 30
  versioning                      = true
  primary_storage_class_retention = 0
  s3_replicas                     = {
    "${module.s3-replica-for-private-bucket.bucket_name}" = {
      # "arn:aws:s3:::staging-storage-ap-southeast-1"
      bucket_arn = module.s3-replica-for-private-bucket.arn
      # "arn:aws:kms:ap-southeast-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      kms_arn = module.s3-replica-for-private-bucket.kms_arn
    }
  }
}

provider "aws" {
  alias  = "replica"
  region = "ap-southeast-1"
}

module "s3-replica-for-private-bucket" {
  source = "github.com/dbl-works/terraform//s3?ref=v2021.07.05"
  providers = {
    aws = "aws.replica"
  }

  region             = "ap-southeast-1"
  environment        = "staging"
  project            = "someproject"
  bucket_name        = "someproject-staging-storage-replica-ap-southeast-1"

  # Optional
  versioning                  = var.versioning
  kms_deletion_window_in_days = 30
  enable_encryption           = true
}

# For public bucket
module "s3-public" {
  source = "github.com/dbl-works/terraform//s3-public?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-frontend"

  # Optional
  versioning                      = false
  primary_storage_class_retention = 0
  s3_replicas                     = {
    "${module.s3-replica-for-public-bucket.bucket_name}" = {
      # "arn:aws:s3:::staging-storage-ap-southeast-1"
      bucket_arn = module.s3-replica-for-public-bucket.arn
    }
  }
}

module "s3-replica-for-public-bucket" {
  source = "github.com/dbl-works/terraform//s3?ref=v2021.07.05"
  providers = {
    aws = "aws.replica"
  }

  region             = 'ap-southeast-1'
  environment        = "staging"
  project            = "someproject"
  bucket_name        = "someproject-staging-frontend-replica-ap-southeast-1"

  # Optional
  versioning                  = var.versioning
  enable_encryption           = false
}
```
