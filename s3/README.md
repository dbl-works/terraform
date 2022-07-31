# Terraform Module: S3

A repository for setting up an S3 bucket

## Usage
### How to create S3 replica for private and public bucket
```terraform
module "s3" {
  source = "../s3"

  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-frontend"

  # Optional
  versioning                  = var.versioning
  kms_deletion_window_in_days = 30
  enable_encryption           = true
}
```
