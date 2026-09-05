# Cloudflare

Terraform modules for Cloudflare.

## Modules

- [zone](zone/README.md) - Zone-scoped resources for one domain: DNS records, DNSSEC, TLS settings, authenticated origin pulls, rulesets, and worker routes.

## Usage

```terraform
module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare/zone?ref=v2022.05.26"

  # ...
}
```

Refer to the module README for variables and recommended usage.
