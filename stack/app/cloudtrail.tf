data "aws_caller_identity" "current" {}

module "log-producer" {
  source = "../../cloudtrail/log-producer"

  environment                       = var.environment
  organization_name                 = var.organization_name
  is_organization_trail             = false
  is_multi_region_trail             = true
  enable_management_cloudtrail      = true
  enable_data_cloudtrail            = var.enable_data_cloudtrail
  s3_bucket_arn_for_data_cloudtrail = var.s3_bucket_arn_for_data_cloudtrail
  cloudtrail_s3_bucket_name         = module.log-ingester.s3_bucket_name
  cloudtrail_s3_kms_arn             = module.log-ingester.s3_kms_arn
}

module "log-ingester" {
  source = "../../cloudtrail/log-ingester"

  environment              = var.environment
  organization_name        = var.organization_name
  log_producer_account_ids = [data.aws_caller_identity.current.account_id]
}

module "s3-cloudtrail-policy" {
  source = "../../cloudtrail/s3-cloudtrail-policy"

  cloudtrail_s3_bucket_name = module.log-ingester.s3_bucket_name
  cloudtrail_arns           = module.log-producer.cloudtrail_arns
}