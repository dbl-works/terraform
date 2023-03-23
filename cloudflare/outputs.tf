output "DNSSEC" {
  description = "Instructions"
  value       = "Add the DNSSEC public key to AWS Route53 -> Under 'Domains' -> 'Registered Domains' -> 'DNSSEC status'"
}

output "dnssec_algorithm" {
  description = "value of the DNSSEC algorithm, e.g. '13' which is 'ECDSA Curve P-256 with SHA-256'"
  value       = cloudflare_zone_dnssec.main.algorithm
}

output "dnssec_key_type" {
  description = "key type of the DNSSEC record, e.g. '257 (KSK)'"
  value       = cloudflare_zone_dnssec.main.key_type
}

output "dnssec_public_key" {
  description = "public key of the DNSSEC record"
  value       = cloudflare_zone_dnssec.main.public_key
}
