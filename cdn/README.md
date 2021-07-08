# Terraform Module: CDN Repository

All ressources required to host a simple CDN.

This will setup:
- S3 bucket "cdn.my-project.com"

## Usage

```terraform
module "cdn" {
  source = "github.com/dbl-works/terraform//cdn?ref=v2021.07.08"

  project     = local.project
  domain_name = "my-project.com"

  # Optional
  additional_allowed_origins = [] # e.g. add "https://my-project-staging.com", "https://*.my-project-staging.com"
}
```


## Outputs
- `dns_target`, Set this as the target for your CNAME record in e.g. Cloudflare.
