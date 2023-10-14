output "s3_bucket_name" {
  value = module.s3-cloudtrail.bucket_name
}

output "s3_kms_arn" {
  value = module.s3-cloudtrail.kms-key-arn
}
