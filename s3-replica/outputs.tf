output "arn" {
  value = aws_s3_bucket.replica.arn
}

output "bucket_name" {
  value = aws_s3_bucket.replica.bucket
}

output "kms_arn" {
  value = length(module.kms_key) > 0 ? module.kms_key[0].arn : null
}
