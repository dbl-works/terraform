# Terraform Module: CDN

A repository for setting up an S3 bucket to host static files such as a frontend app, images, fronts, etc.

To ensure we access files using a SSL encrypted protocol, we have two possibilities:
- use a CloudFront Distribution (available in versions `v2021.07.30` to `v2021.10.09`)
- use Cloudflare to route to the HTTPS URL of the file

The first option comes with quite some overhead, and is less flexible (e.g. hosting a second app in the same bucket and have it accessed from a different URL requires additional AWS Lambdas to intercept the request; we would need a SSL certificate residing in `us-east-1` as a hard requirement, etc.).

Thus, we choose to use a Cloudflare Worker. Technically, it still intercepts the request and manipulates it as needed,
however, this happens on the edge rather than in our server location, and thus is much faster.
Also, Cloudflare Workers offer more flexibility with less overhead in infrastructure.

Find our standarized way for Cloudflare Workers in this [repo](https://github.com/cloudflare/workers) (TODO: actual link still pending).

To ensure a consistent standard across all projects, we recommend having the following two CDNs for every project and every environment (as far as needed):
1. `cdn`, i.e. `domain_name` = `cdn.my-project.cloud` (staging), or `cdn.my-project.com` (production)
   use this bucket for hosting all frontend applications and public files (e.g. fonts, images for the website, et.c)
2. `storage`, i.e. `domain_name` = `storage.my-project.com`
   use this bucket for storing files specific to user/customer related records, for example invoices, user specific files, etc.

The bucket is set to `private`, hence on sync you will have to be explicit if some files should be public:

```shell
aws s3 sync --acl public-read ./ s3://cdn.my-project.com/
```


## Usage

```terraform
module "cdn" {
  source = "github.com/dbl-works/terraform//cdn?ref=vXXX"

  environment = local.environment
  project     = local.project
  domain_name = "cdn.my-project.com"   # or e.g. "storage.my-project.com"

  # optional
  single_page_application = false
  index_document          = "index.html"
  error_document          = "404.html"
  routing_rules           = ""
}
```

Setting `single_page_application` to `true` will redirect all `404` requests (i.e. `mypage.com/xx`) back to root (i.e. `mypage.com/`).

You could define `routing_rules` for example as follows, but the prefered way is to use a Cloudflare Worker.

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

## Outputs
- `dns_target`, Set this as the target for your CNAME record in e.g. Cloudflare (without the `https://` prefix).
