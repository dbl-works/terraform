output "arn" {
  value = module.s3.arn
}

output "kms-key-arn" {
  value = module.s3.kms_arn
}

output "group-usage-name" {
  value = aws_iam_group.usage.name
}
