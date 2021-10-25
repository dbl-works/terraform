output "dns_target" {
  value       = aws_cloudfront_distribution.main.domain_name
  description = "Set this as the target for your CNAME record in e.g. Cloudflare."
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.main.id
  description = "The identifier for the distribution. For example: EDFDVBD632BHDS5."
}
