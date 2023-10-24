locals {
  cloudtrail_name = "${var.organization_name}-cloudtrail-logs"
}

# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-receive-logs-from-multiple-accounts.html
# The aws cloudtrail for the ingester account has to be created before the cloudtrail event in producer account
resource "aws_cloudtrail" "management" {
  name                          = local.cloudtrail_name
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = module.s3-cloudtrail.kms-key-arn
  s3_bucket_name                = module.s3-cloudtrail.bucket_name

  advanced_event_selector {
    name = "Log readOnly and writeOnly management events"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  tags = {
    Name        = local.cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_policy.allow_access_from_cloudtrail_only]
}
