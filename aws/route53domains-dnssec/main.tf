resource "aws_route53domains_delegation_signer_record" "main" {
  domain_name = var.domain_name

  signing_attributes {
    algorithm  = var.dnssec_algorithm
    flags      = var.dnssec_flags
    public_key = var.dnssec_public_key
  }

  lifecycle {
    create_before_destroy = true

    # The Route 53 Domains API does not return flags/public_key as separate
    # fields, so the provider nulls them on every refresh and import, which
    # would otherwise force a bogus replacement on each plan. The key ID still
    # tracks the real registrar state. To rotate the key deliberately, run:
    #   terraform apply -replace=<address of this resource>
    ignore_changes = [signing_attributes]
  }
}
