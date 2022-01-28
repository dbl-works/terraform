output "arn" {
  value = aws_s3_bucket.main.arn
}

output "kms-key-arn" {
  value = module.kms-key-s3.arn
}

output "group-usage-name" {
  value = aws_iam_group.usage.name
}
