# Terraform Module: Cloudflare

This module will do the following:

- Domain validation
  - Configure a CNAME record in DNS configuration to establish control of your domain name. This allows ACM to automatically renew DNS-validated certificates before they expire, as long as the DNS record has not changed
- Route to defaults routes
    - api.my-project.com to the NLB
    - bastion.my-project.com
    - cdn.my-project.com to the S3-Bucket (using Cloudflare Workers)
    - xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed

## Pre-setup
1. Setup and publish your CDN cloudflare worker.
- Some useful references:
  - Quickstart: https://developers.cloudflare.com/workers/get-started/quickstarts/
  - Cloudflare CDN tutorials: https://developers.cloudflare.com/workers/tutorials/configure-your-cdn/
  - Introduction to Cloudflare Worker: https://egghead.io/courses/introduction-to-cloudflare-workers-5aa3
  - Cloudflare Router: https://github.com/dbl-works/cloudflare-router

2. Make sure you have created an API token in your Cloudflare account with sufficient permissions
- You can have a look at the cloudflare permissions [here](https://developers.cloudflare.com/api/tokens/create/permissions/)
- You should have access to
  - All zones - Zone:Edit, Workers Routes:Edit, DNS:Edit

## Usage

```terraform
module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare?ref=v2022.05.26"

  domain = "example.com"
  subject_alternative_names = ["*.example.com"]
  nlb_dns_name = "project-staging-xxxxxxx.eu-central-1.elb.amazonaws.com"
  cdn_worker_script_name = "serve-cdn"
  s3_public_buckets = [
    {
      name = "a-bucket "
      cdn_path = "cdn"
    },
    {
      name = "b-bucket "
      cdn_path = "images"
    }
   ]

  # Refer to the output value in certificate/outputs.tf
  certificate_resource_record_name = module.certificate.domain_validation_information.0.resource_record_name
  certificate_resource_record_type = module.certificate.domain_validation_information.0.resource_record_type
  certificate_resource_record_value = module.certificate.domain_validation_information.0.resource_record_value

  # optional
  bastion_public_dns = "project-staging-xxxxx.elb.eu-central-1.amazonaws.com"
}
```
