# Terraform Module: CDN

A repository for setting up an S3 bucket to host static files such as a frontend app, images, fronts, etc.

Access is permitted only through a Cloudfront distribution that requires an SSL certificate for your custom domain.


## Usage

```terraform
module "cdn" {
  source = "github.com/dbl-works/terraform//cdn?ref=v2021.07.XX" # @TODO: update on release

  environment     = local.environment
  project         = local.project
  domain_name     = "cdn.my-project.com"
  certificate_arn = module.cdn-certificate.arn # requires a `certificate` module to be created separately

  # optional
  price_class = "PriceClass_100" # For Cloudfront, other values: PriceClass_All, PriceClass_200
}
```

:warning: The certificate MUST be in `us-east-1` to be associatable with a CloudFront distribution.

You can add a second provider, according to the [docs](https://www.terraform.io/docs/configuration-0-11/providers.html#multiple-provider-instances)

```terraform
provider "aws" {
  alias   = "acm"       # Amazon Certificate Manager
  region  = "us-east-1" # AWS ACM MUST be in us-east-1 to work for cloudfron
  profile = "your-profile-name"
}
```

then create your certificate in this region

```terraform
resource "aws_acm_certificate" "cdn" {
  provider    = "aws.acm"

  domain_name       = "cdn.my-project.com"
  validation_method = "DNS"

  tags = {
    Name        = var.domain_name
    Project     = var.project
    Environment = var.environment
  }
}
```

## Outputs
- `dns_target`, Set this as the target for your CNAME record in e.g. Cloudflare (without the `https://` prefix).
