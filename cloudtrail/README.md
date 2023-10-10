# Terraform Module: Cloudtrail

This Terraform module allows you to easily create and configure AWS CloudTrail resources. AWS CloudTrail is a service that records API calls made on your AWS account and delivers log files to an Amazon S3 bucket for analysis, compliance, and security auditing.

## Features

- Create a new CloudTrail trail.
- Configure the trail with your desired settings.
- Define the S3 bucket where CloudTrail log files will be stored.

## Usage

```terraform
# In logging account
module "logging-account" {
  source = "github.com/dbl-works/terraform//cloudtrail/logging-account"

  environment = local.environment
  organization_name = "test-organization"
  is_organization_trail = true
  is_multi_region_trail = true
  enable_management_cloudtrail = true
  enable_data_cloudtrail = true
}

module "logs-destination-account" {
  source = "github.com/dbl-works/terraform//cloudtrail/logs-destination-account"

  environment = local.environment
  organization_name = "test-organization"
  cloudtrail_roles = []
}
```
