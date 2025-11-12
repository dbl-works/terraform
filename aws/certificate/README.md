# Terraform Module: SSL Certificate

Requests a certificate from the Amazon Certificate Manager.

:warning: This module MUST be created before other modules that depend on it.
Take the validation information from the output, then perform the validation with your provider (e.g. on Cloudflare).
Some resources depend on the certificate being created **and** validated, for example Listeners for Load Balancers.
Thus, creating those will fail if the certificate has not been validated (manually) in a previous step.



## Usage

```terraform
# :warning: MUST be created and manually validated before any depending resources
module "certificate" {
  source = "github.com/dbl-works/terraform//aws/certificate?ref=main"

  project     = "someproject"
  environment = "staging"
  domain_name = "my-domain.com"

  # Optional
  add_wildcard_subdomains = true
  alternative_domains = [
    "www.example.com",
    "another.domain.co.uk",
  ]
}
```

Setting `add_wildcard_subdomains` to `false` will omit creating a wild-card certificate for subdomains, i.e. `*.${domain-name}`.

You might want to user a more recent `ref`.



## Outputs
- `domain_validation_information`, used to validate DNS records
- `arn`
