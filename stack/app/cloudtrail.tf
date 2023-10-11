data "aws_caller_identity" "current" {}

module "logging-account" {
  source = "../../cloudtrail/logging-account"

  environment                       = var.environment
  organization_name                 = var.organization_name
  is_organization_trail             = false
  is_multi_region_trail             = true
  enable_management_cloudtrail      = true
  enable_data_cloudtrail            = var.enable_data_cloudtrail
  s3_bucket_arn_for_data_cloudtrail = var.s3_bucket_arn_for_data_cloudtrail
  cloudtrail_s3_bucket_name         = module.logs-destination-account.s3_bucket_name
}

module "logs-destination-account" {
  source = "../../cloudtrail/logs-destination-account"

  environment         = var.environment
  organization_name   = var.organization_name
  logging_account_ids = [data.aws_caller_identity.current.account_id]
}
