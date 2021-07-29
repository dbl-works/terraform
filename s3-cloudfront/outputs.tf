output "dns_target" {
  value = aws_cloudfront_distribution.main.domain_name
}
