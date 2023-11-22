# Bucket information
output "s3_bucket_name" {
  value = module.s3-cloudtrail.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3-cloudtrail.bucket_arn
}

output "s3_bucket_region" {
  value = data.aws_region.current.name
}

# KMS information
output "s3_kms_arn" {
  value = module.s3-cloudtrail.kms-key-arn
}

output "s3_kms_key_id" {
  value = module.s3-cloudtrail.kms-key-id
}
