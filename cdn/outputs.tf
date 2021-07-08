output "dns_target" {
  value       = aws_s3_bucket.main.website_endpoint
  description = "Set this as the target for your CNAME record in e.g. Cloudflare."
}
