# Terraform Module: S3-Cloudfront

A reopsitory for setting up a S3 bucket to host a static website/frontend app. Access is granted through Cloudfront, which has an endpoint with a SSL certificate.


## Usage

```terraform
module "s3-cloudfront" {
  source = "github.com/dbl-works/terraform//s3-cloudfront?ref=v2021.07.XX" # @TODO: update on release

  environment = local.environment
  project     = local.project
  domain_name = "my-project.com"

  # optional
  price_class = "PriceClass_100" # others: PriceClass_All, PriceClass_200
}
```


## Outputs
- `cloudfront_endpoint`, point your Domain to this, e.g. using Cloudfront
