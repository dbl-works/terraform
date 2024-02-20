output "domain_validation_information" {
  value       = aws_acm_certificate.main.domain_validation_options
  description = "Used to complete certificate validation, e.g. in Cloudflare."
}

output "arn" {
  value = aws_acm_certificate.main.arn
}

output "domain_name" {
  value = aws_acm_certificate.main.domain_name
}
