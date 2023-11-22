locals {
  cloudtrail_name = "protected-${var.organization_name}-cloudtrail-logs"
}

# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-receive-logs-from-multiple-accounts.html
# The aws cloudtrail for the ingestor account has to be created before the cloudtrail event in producer account
resource "aws_cloudtrail" "management" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = local.cloudtrail_name
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = module.s3-cloudtrail.kms-key-arn
  s3_bucket_name                = module.s3-cloudtrail.bucket_name

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    exclude_management_event_sources = [
      # AWS KMS actions such as Encrypt, Decrypt, and GenerateDataKey typically generate a large volume (more than 99%) of events.
      "kms.amazonaws.com",
      # CloudTrail captures all API calls for Data API as events, including calls from the Amazon RDS console and from code calls to the Data API operations
      # However, the Data API can generate a large number of events,
      "rdsdata.amazonaws.com"
    ]
  }

  tags = {
    Name        = local.cloudtrail_name
    Project     = var.organization_name
    Environment = var.environment
  }

  depends_on = [aws_s3_bucket_policy.allow_access_from_cloudtrail_only]
}
