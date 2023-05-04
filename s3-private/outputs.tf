output "id" {
  value = module.s3.id
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "arn" {
  value = module.s3.arn
}

output "kms-key-arn" {
  value = module.s3.kms_arn
}

output "group-usage-name" {
  value = aws_iam_group.usage.name
}

output "policy_arn" {
  value = aws_iam_policy.usage.arn
}
