mock_provider "aws" {}

run "registers_cloudflare_ksk_with_route53_domains" {
  command = plan

  variables {
    domain_name       = "example.com"
    dnssec_algorithm  = 13
    dnssec_key_type   = 257
    dnssec_public_key = "mdsswUyr3DPW132mOi8V9xESWEkK2G8gkJ7FZ0PQcqGd9M6FtdV7oNXgYw=="
  }

  assert {
    condition     = aws_route53domains_delegation_signer_record.main.domain_name == "example.com"
    error_message = "The Route 53 Domains delegation signer must target the registered domain."
  }

  assert {
    condition     = aws_route53domains_delegation_signer_record.main.signing_attributes[0].algorithm == 13
    error_message = "The delegation signer must use Cloudflare's DNSSEC algorithm."
  }

  assert {
    condition     = aws_route53domains_delegation_signer_record.main.signing_attributes[0].flags == 257
    error_message = "The delegation signer must register Cloudflare's key-signing key."
  }

  assert {
    condition     = aws_route53domains_delegation_signer_record.main.signing_attributes[0].public_key == var.dnssec_public_key
    error_message = "The delegation signer must register Cloudflare's public key without manual copying."
  }
}
