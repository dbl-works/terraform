data "aws_caller_identity" "current" {}

module "log-producer" {
  count  = var.cloudtrail_producer_config == null ? 0 : 1
  source = "../../cloudtrail/log-producer"

  environment                        = var.environment
  project                            = var.project
  is_organization_trail              = false
  is_multi_region_trail              = true
  enable_management_cloudtrail       = true
  enable_data_cloudtrail             = var.cloudtrail_producer_config.enable_data_cloudtrail
  s3_bucket_arns_for_data_cloudtrail = var.cloudtrail_producer_config.s3_bucket_arns_for_data_cloudtrail
  cloudtrail_target_bucket_name      = var.is_cloudtrail_log_ingestor ? module.log-ingestor[0].s3_bucket_name : var.cloudtrail_producer_config.cloudtrail_target_bucket_name
  cloudtrail_target_bucket_kms_arn   = var.is_cloudtrail_log_ingestor ? module.log-ingestor[0].s3_kms_arn : var.cloudtrail_producer_config.cloudtrail_target_bucket_kms_arn
}

module "log-ingestor" {
  count  = var.is_cloudtrail_log_ingestor ? 1 : 0
  source = "../../cloudtrail/log-ingestor"

  environment              = var.environment
  project                  = var.project
  log_producer_account_ids = [data.aws_caller_identity.current.account_id]
}

module "s3-cloudtrail-policy" {
  source = "../../cloudtrail/s3-cloudtrail-policy"

  cloudtrail_target_bucket_name = var.is_cloudtrail_log_ingestor ? module.log-ingestor[0].s3_bucket_name : var.cloudtrail_producer_config.cloudtrail_target_bucket_name
  cloudtrail_arns = concat(
    var.is_cloudtrail_log_ingestor ? [module.log-ingestor[0].cloudtrail_arn] : [],
    var.cloudtrail_producer_config == null ? [] : module.log-producer[0].cloudtrail_arns
  )
}
