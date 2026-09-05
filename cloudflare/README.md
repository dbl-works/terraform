# Cloudflare

Terraform modules for Cloudflare.

## Modules

- [zone](zone/README.md) - Zone-scoped resources for one domain: DNS records, DNSSEC, TLS settings, authenticated origin pulls, rulesets, and worker routes.
- [zero-trust](zero-trust/README.md) - Cloudflare Access login in front of selected hostnames. Allow users by email, no user management in the app.

## Usage

```terraform
module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare/zone?ref=v2022.05.26"

  # ...
}

module "cloudflare_zero_trust" {
  source = "github.com/dbl-works/terraform//cloudflare/zero-trust?ref=v2026.09.05"

  # ...
}
```

Refer to the module README for variables and recommended usage.
