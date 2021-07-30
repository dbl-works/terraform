# Terraform Module: CDN

A repository for setting up an S3 bucket to host static files such as a frontend app, images, fronts, etc.

Access is permitted only through a Cloudfront distribution that requires an SSL certificate for your domain. Due to Cloudfront limitations, this certificate must be in `us-east-1` (find more details on this below).


## Usage

```terraform
module "cdn" {
  source = "github.com/dbl-works/terraform//cdn?ref=v2021.07.XX"

  environment     = local.environment
  project         = local.project
  domain_name     = "cdn.my-project.com"        # or e.g. "admin.my-project.com"
  certificate_arn = aws_acm_certificate.cdn.arn # requires a `certificate` module to be created separately

  # optional
  price_class             = "PriceClass_100"
  single_page_application = false
  index_document          = "index.html"
  error_document          = "404.html"
  routing_rules           = ""
}
```

The `PriceClass_100` serves requests from `North America` and `Europa`; all other regions might see an increased latency. Other possible values are: `PriceClass_All`, and `PriceClass_200`.

Setting `single_page_application` to `true` will redirect all `404` requests (i.e. `mypage.com/xx`) back to root (i.e. `mypage.com/`).

Set `routing_rules` e.g. as:

```
routing_rules = <<EOF
  [{
    "Condition": {
      "KeyPrefixEquals": "myprefix/"
    },
    "Redirect": {
      "HostName": "www.example.com",
      "HttpRedirectCode": "302",
      "Protocol": "https"
    }
  }]
EOF
```

:warning: The certificate MUST be in `us-east-1` to be associatable with a CloudFront distribution, [read the docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html).

You can add a second provider, according to the [docs](https://www.terraform.io/docs/configuration-0-11/providers.html#multiple-provider-instances)

```terraform
provider "aws" {
  alias   = "acm"       # Amazon Certificate Manager
  region  = "us-east-1" # AWS ACM MUST be in us-east-1 to work for Cloudfront
  profile = "your-profile-name"
}
```

then create your certificate in this region; Just create a wildcard one, in case you need multiple CDNs.

```terraform
resource "aws_acm_certificate" "cdn" {
  provider = aws.acm

  domain_name       = local.root_url
  validation_method = "DNS"

  subject_alternative_names = ["*.${local.root_url}"]

  tags = {
    Name        = local.root_url
    Project     = local.project
    Environment = local.environment
  }
}
```

## Outputs
- `dns_target`, Set this as the target for your CNAME record in e.g. Cloudflare (without the `https://` prefix).
