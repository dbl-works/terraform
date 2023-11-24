data "aws_caller_identity" "current" {}

module "log-producer" {
  source = "../../cloudtrail/log-producer"

  environment                        = var.environment
  project                            = var.project
  is_organization_trail              = false
  is_multi_region_trail              = true
  enable_management_cloudtrail       = true
  enable_data_cloudtrail             = var.enable_data_cloudtrail
  s3_bucket_arns_for_data_cloudtrail = var.s3_bucket_arns_for_data_cloudtrail
  cloudtrail_target_bucket_name      = module.log-ingestor.s3_bucket_name
  cloudtrail_target_bucket_kms_arn   = module.log-ingestor.s3_kms_arn
}

module "log-ingestor" {
  source = "../../cloudtrail/log-ingestor"

  environment              = var.environment
  project                  = var.project
  log_producer_account_ids = [data.aws_caller_identity.current.account_id]
}

module "s3-cloudtrail-policy" {
  source = "../../cloudtrail/s3-cloudtrail-policy"

  cloudtrail_target_bucket_name = module.log-ingestor.s3_bucket_name
  cloudtrail_arns               = module.log-producer.cloudtrail_arns
}
