output "arn" {
  value = aws_s3_bucket.main.arn
}

output "id" {
  value = aws_s3_bucket.main.id
}

output "bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "kms_arn" {
  value = length(module.kms_key) > 0 ? module.kms_key[0].arn : null
}
