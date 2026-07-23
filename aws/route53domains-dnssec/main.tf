resource "aws_route53domains_delegation_signer_record" "main" {
  domain_name = var.domain_name

  signing_attributes {
    algorithm  = var.dnssec_algorithm
    flags      = var.dnssec_key_type
    public_key = var.dnssec_public_key
  }

  lifecycle {
    create_before_destroy = true
  }
}
