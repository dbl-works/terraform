# Terraform Module: Cloudtrail

This Terraform module allows you to create and configure AWS CloudTrail resources. AWS CloudTrail is a service that records API calls made on your AWS account and delivers log files to an Amazon S3 bucket for analysis, compliance, and security auditing.

## Features

- Create a new CloudTrail trail.
- Configure the trail with your desired settings.
- Define the S3 bucket where CloudTrail log files will be stored.

## Usage

```terraform
# log-destination Account
provider "aws" {
  region  = var.region
  profile = "log-destination"
  alias   = "log-destination"
}

# Logging Account
provider "aws" {
  region  = var.region
  profile = "logging"
  alias   = "logging"
}

data "aws_caller_identity" "current" {
  provider = aws.logging
}

# In logging account
module "logging-account" {
  provider = aws.logging

  source = "github.com/dbl-works/terraform//cloudtrail/logging-account"

  environment = local.environment
  organization_name = "test-organization"
  is_organization_trail = true
  is_multi_region_trail = true
  enable_management_cloudtrail = true
  enable_data_cloudtrail = true
  s3_bucket_arn_for_data_cloudtrail = [
    "arn:aws:s3:::bucket_name/important_s3_bucket",
    "arn:aws:s3:::bucket_name/second-important_s3_bucket/prefix",
  ]
  log_retention_days = 21
}

module "logs-destination-account" {
  provider = aws.log-destination

  source = "github.com/dbl-works/terraform//cloudtrail/logs-destination-account"

  environment = local.environment
  organization_name = "test-organization"
  logging_account_ids = [data.aws_caller_identity.current.account_id]
}
```
