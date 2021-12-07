# Terraform Module: s3-storage

Standarized set up for a private, encrypted S3 bucket with versioning.
Used for any private files from an application, e.g. PDF files linked to a record.


## Usage

```terraform
module "s3-storage" {
  source = "github.com/dbl-works/terraform//s3-storage?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  domain_name = "example.com"

  # Optional
  kms_deletion_window_in_days = 30
}
```


## Outputs

- `arn`: you probably want to pass this arn to ECS' `grant_write_access_to_s3_arns`
- `kms-key-arn`: you probably want to pass this arn to ECS' `kms_key_arns`
