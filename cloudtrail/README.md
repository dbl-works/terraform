# Terraform Module: Cloudtrail

This Terraform module allows you to create and configure AWS CloudTrail resources. AWS CloudTrail is a service that records API calls made on your AWS account and delivers log files to an Amazon S3 bucket for analysis, compliance, and security auditing.

## Features

- Create a new CloudTrail trail.
- Configure the trail with your desired settings.
- Define the S3 bucket where CloudTrail log files will be stored.

## Usage

```terraform
provider "aws" {
  region  = var.region
  profile = "log-ingester"
  alias   = "log-ingester"
}

provider "aws" {
  region  = var.region
  profile = "log-producer"
  alias   = "log-producer"
}

data "aws_caller_identity" "current" {
  provider = aws.log-producer
}

module "log-producer" {
  providers = {
    aws = aws.log-producer
  }

  source = "github.com/dbl-works/terraform//cloudtrail/logging-account"

  environment = local.environment
  organization_name = "test-organization"
  is_organization_trail = true
  is_multi_region_trail = true
  enable_management_cloudtrail = true
  enable_data_cloudtrail = true
  cloudtrail_s3_bucket_name = "cloudtrail-for-test-organization"
  cloudtrail_s3_kms_arn = "arn:aws:kms:eu-central-1:xxxxxxxxxxxx:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  s3_bucket_arn_for_data_cloudtrail = [
    "arn:aws:s3:::bucket_name/important_s3_bucket",
    "arn:aws:s3:::bucket_name/second-important_s3_bucket/prefix",
  ]
  log_retention_days = 14
}

module "log-ingester" {
  providers = {
    aws = aws.log-ingester
  }

  source = "github.com/dbl-works/terraform//cloudtrail/log-ingester"

  environment = local.environment
  organization_name = "test-organization"
  log_producer_account_ids = [data.aws_caller_identity.current.account_id]
}
```
