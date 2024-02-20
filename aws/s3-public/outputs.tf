output "arn" {
  description = "S3 bucket amazon resources name"
  value       = module.s3.arn
}

output "id" {
  description = "S3 bucket ID"
  value       = module.s3.id
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}
