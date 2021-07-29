# Terraform Module: CDN

A reopsitory for setting up a S3 bucket to host static files such as a frontend app, images, fronts, etc.

Access is permitted only through a Cloudfront distribution, that requires a SSL certificate for your custom domain.


## Usage

```terraform
module "cdn" {
  source = "github.com/dbl-works/terraform//cdn?ref=v2021.07.XX" # @TODO: update on release

  environment     = local.environment
  project         = local.project
  domain_name     = "my-project.com"
  certificate_arn = module.ssl-certificate.arn # requires a `certificate` module to be created separately

  # optional
  price_class = "PriceClass_100" # For Cloudfront, other values: PriceClass_All, PriceClass_200
}
```


## Outputs
- `dns_target`, Set this as the target for your CNAME record in e.g. Cloudflare (without the `https://` prefix).
