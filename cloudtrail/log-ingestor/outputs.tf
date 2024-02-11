# Bucket information
output "s3_bucket_name" {
  value = module.s3-cloudtrail.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3-cloudtrail.arn
}

# KMS information
output "s3_kms_arn" {
  value = module.s3-cloudtrail.kms-key-arn
}

output "s3_kms_key_id" {
  value = module.s3-cloudtrail.kms-key-id
}

output "cloudtrail_arn" {
  value = var.enable_cloudtrail ? aws_cloudtrail.management[0].arn : ""
}
