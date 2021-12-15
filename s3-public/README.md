# Terraform Module: CDN

A repository for setting up an S3 bucket to host public files such as a frontend app, images, fronts, etc.

If you want to host multiple apps, you can use the [DBL Cloudflare Router](https://github.com/dbl-works/cloudflare-router) to route certain URLs to specific paths in this bucket.



## Usage

```terraform
module "s3-frontend" {
  source = "github.com/dbl-works/terraform//s3-public?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "someproject-staging-frontend"

  # Optional
  versioning = false
  primary_storage_class_retention = 0
}
```



## Outputs

- `arn`: you probably want to pass this arn to ECS `grant_read_access_to_s3_arns`
