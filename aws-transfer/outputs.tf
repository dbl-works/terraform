output "endpoint" {
  value = aws_transfer_server.main.endpoint
}

output "s3_arn" {
  value = module.s3-storage.arn
}
