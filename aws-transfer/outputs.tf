output "endpoint" {
  value = aws_transfer_server.main.endpoint
}

output "aws_transfer_server_id" {
  value = aws_transfer_server.main.id
}

output "s3_arn" {
  value = var.s3_bucket_name == null ? "" : module.s3-storage[0].arn
}

output "s3_kms_arn" {
  value = var.s3_bucket_name == null ? "" : module.s3-storage[0].kms-key-arn
}
