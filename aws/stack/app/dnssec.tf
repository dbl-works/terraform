module "route53domains_dnssec" {
  source = "../../route53domains-dnssec"
  count  = var.route53domains_dnssec_enabled && !var.skip_cloudflare ? 1 : 0

  providers = {
    aws = aws.us-east-1
  }

  domain_name       = var.domain_name
  dnssec_algorithm  = tonumber(module.cloudflare[0].dnssec_algorithm)
  dnssec_flags      = module.cloudflare[0].dnssec_flags
  dnssec_public_key = module.cloudflare[0].dnssec_public_key
}
