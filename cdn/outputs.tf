output "dns_target" {
  value       = aws_s3_bucket.main.website_endpoint
  description = "Set this as a target for your CNAME record in e.g. Cloudflare."
}
