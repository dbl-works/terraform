# Terraform Module: s3-storage

Standarized set up for a private, encrypted S3 bucket with versioning.
Used for any private files from an application, e.g. PDF files linked to a record.



## Usage

```terraform
module "s3-storage" {
  source = "github.com/dbl-works/terraform//s3-private?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-storage"

  # Optional
  kms_deletion_window_in_days     = 30
  versioning                      = true
  regional                        = false
  region                          = ""   # IAM Policy Names must be unique across regions
  name                            = ""   # used for policies, if null "project-environment-region" is used
  primary_storage_class_retention = 0
  s3_replicas                     = {
    staging-storage-us-east-1 = {
      bucket_arn = "arn:aws:s3:::staging-storage-us-east-1"
      kms_arn = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    }
  }
}
```



## Outputs

- `arn`: you probably want to pass this arn to ECS `grant_write_access_to_s3_arns`
- `kms-key-arn`: you probably want to pass this arn to ECS `kms_key_arns`
- `group-usage-name`: name of the AWS IAM group to grant usage permissions to the bucket
