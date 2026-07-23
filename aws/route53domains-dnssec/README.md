# Route 53 Domains DNSSEC Registration

Registers a DNSSEC key from an external authoritative DNS provider, such as Cloudflare, with a domain purchased through Route 53 Domains. This module does not create or sign a Route 53 hosted zone.

Route 53 Domains API operations only run in `us-east-1`, so pass an AWS provider configured for that region:

```hcl
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "route53domains_dnssec" {
  source = "github.com/dbl-works/terraform//aws/route53domains-dnssec?ref=main"

  providers = {
    aws = aws.us-east-1
  }

  domain_name       = "example.com"
  dnssec_algorithm  = tonumber(module.cloudflare.dnssec_algorithm)
  dnssec_flags      = module.cloudflare.dnssec_flags
  dnssec_public_key = module.cloudflare.dnssec_public_key
}
```

## Existing manually registered keys

Do not create a duplicate registrar key. Import the existing Route 53 Domains key before enabling management in a stack:

```shell
terraform import 'module.route53domains_dnssec.aws_route53domains_delegation_signer_record.main' 'example.com,DNSSEC_KEY_ID'
```

The key ID is visible under Route 53 → Registered domains → the domain → DNSSEC keys, or through `aws route53domains get-domain-detail --region us-east-1 --domain-name example.com`.

## Safe key replacement and removal

DNSSEC changes require an overlap period because resolvers cache DS and DNSKEY records. The resource uses `create_before_destroy`, so Terraform adds a replacement key before requesting deletion of the old key. This guarantees ordering, but it does not wait between those operations.

If a plan replaces the signing key, do not apply it as one immediate replacement. Temporarily manage the new key alongside the old key, confirm that both keys have reached the parent registry, and wait for the DS record TTL to expire before removing the old key. Route 53 recommends waiting up to three days after adding the new key.

To disable DNSSEC or destroy the Cloudflare zone safely:

1. Remove the registrar key first, for example by setting `route53domains_dnssec_enabled = false`, and apply.
2. Keep Cloudflare DNSSEC signing enabled while the old DS record can still be cached.
3. Wait for the DS TTL to expire; Route 53 recommends up to three days.
4. Only then disable Cloudflare DNSSEC or destroy the Cloudflare resources.

Disabling signing while a DS record still exists can make the entire domain return `SERVFAIL` to validating resolvers. See the [Route 53 DNSSEC key replacement and removal guidance](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-configure-dnssec.html).
