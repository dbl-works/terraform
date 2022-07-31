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
  versioning                      = false
  primary_storage_class_retention = 0
  s3_replicas                     = []
}
```

### With replica
```terraform
module "s3-public" {
  source = "github.com/dbl-works/terraform//s3-public?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "${var.bucket_name}-public"

  # Optional
  versioning                      = true
  primary_storage_class_retention = 0
  s3_replicas                     = [
    {
      bucket_arn = module.s3-public-eu-central-1.arn
    },
    {
      bucket_arn = module.s3-public-us-east-1.arn
    }
   ]
}

provider "aws" {
  alias  = "eu"
  region = "eu-central-1"
}

module "s3-public-eu-central-1" {
  source = "github.com/dbl-works/terraform//s3-public?ref=v2021.11.13"
  providers = {
    aws = aws.eu
  }

  environment        = "staging"
  project            = "someproject"
  bucket_name = "${var.bucket_name}-public-eu-central-1"
  s3_replicas = [
    {
      bucket_arn = module.s3-public.arn
    },
    {
      bucket_arn = module.s3-public-us-east-1.arn
    }
  ]

  # Optional
  versioning                  = true
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

module "s3-public-us-east-1" {
  source = "github.com/dbl-works/terraform//s3-public?ref=v2021.11.13"

  # Required
  environment = "staging"
  project     = "someproject"
  bucket_name = "${var.bucket_name}-public-us-east-1"

  # Optional
  versioning                      = true
  primary_storage_class_retention = 0
  s3_replicas = [
    {
      bucket_arn = module.s3-public.arn
    },
    {
      bucket_arn = module.s3-public-eu-central-1.arn
    },
   ]
}
```

## Outputs

- `arn`: you probably want to pass this arn to ECS `grant_read_access_to_s3_arns`
