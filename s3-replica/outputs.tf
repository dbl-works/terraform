output "arn" {
  value = aws_s3_bucket.replica.arn
}

output "bucket_name" {
  value = aws_s3_bucket.replica.bucket
}

output "kms_arn" {
  value = module.kms_key.*.arn[0]
}
