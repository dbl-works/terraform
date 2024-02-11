# Terraform Module: Cloudtrail

This Terraform module allows you to create and configure AWS CloudTrail resources. AWS CloudTrail is a service that records API calls made on your AWS account and delivers log files to an Amazon S3 bucket for analysis, compliance, and security auditing.

## Features

- Create a new CloudTrail trail.
- Configure the trail with your desired settings.
- Define the S3 bucket where CloudTrail log files will be stored.
- Define SCP policy to restrict users from modifying or deleting CloudTrail logs.

## Usage

```terraform
provider "aws" {
  region  = var.region
  profile = "log-ingestor"
  alias   = "log-ingestor"
}

provider "aws" {
  region  = var.region
  profile = "log-producer"
  alias   = "log-producer"
}

provider "aws" {
  region  = var.region
  profile = "management-account"
  alias   = "management-account"
}

data "aws_caller_identity" "log_producer" {
  provider = aws.log-producer
}

module "log-ingestor" {
  providers = {
    aws = aws.log-ingestor
  }

  source = "github.com/dbl-works/terraform//cloudtrail/log-ingestor"

  environment = local.environment
  project = "test-organization"
  log_producer_account_ids = [data.aws_caller_identity.log_producer.account_id]

  # Optional
  enable_cloudtrail = false
}

module "log-producer" {
  providers = {
    aws = aws.log-producer
  }

  source = "github.com/dbl-works/terraform//cloudtrail/log-producer"

  environment = local.environment
  project = "test-organization"
  is_organization_trail = false
  is_multi_region_trail = true
  enable_management_cloudtrail = true
  enable_data_cloudtrail = true
  cloudtrail_target_bucket_name = module.log-ingestor.s3_bucket_name
  cloudtrail_target_bucket_kms_arn = module.log-ingestor.s3_kms_arn
  s3_bucket_arns_for_data_cloudtrail = [
    "arn:aws:s3:::bucket_name/important_s3_bucket",
    "arn:aws:s3:::bucket_name/second-important_s3_bucket/prefix",
  ]
  log_retention_days = 14
}

module "s3-cloudtrail-policy" {
  providers = {
    aws = aws.log-ingestor
  }

  source = "github.com/dbl-works/terraform//cloudtrail/s3-cloudtrail-policy"

  cloudtrail_target_bucket_name = module.log-ingestor.s3_bucket_name
  cloudtrail_arns = module.log-producer.cloudtrail_arns
}

module "cloudtrail_protection_scp" {
  providers = {
    aws = aws.management-account
  }

  source = "github.com/dbl-works/terraform//cloudtrail/cloudtrail-protection-scp"

  # Best practice is to never attach SCPs to the root of your organization. Instead, create an Organizational Unit (OU) underneath root and attach policies there.
  target_ids = [data.aws_caller_identity.log_producer.account_id]
}
```

### Enable SCP Policy

- Before applying the cloudtrail-protection-scp module, ensure that you have enabled the Service Control Policy (SCP).
- To enable SCP, navigate to AWS Organizations > Policies > Service Control Policies, then click on "Enable Service Control Policies."
  https://us-east-1.console.aws.amazon.com/organizations/v2/home/policies
