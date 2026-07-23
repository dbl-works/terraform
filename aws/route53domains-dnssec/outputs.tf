output "dnssec_key_id" {
  description = "Route 53 Domains identifier assigned to the delegation signer record."
  value       = aws_route53domains_delegation_signer_record.main.dnssec_key_id
}
