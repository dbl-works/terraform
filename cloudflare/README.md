# Terraform Module: Cloudflare

Setting up the following in this repository:

- Domain validation
- Route to defaults routes
    - api.my-project.com to the NLB
    - bastion.my-project.com
    - cdn.my-project.com to the S3-Bucket (using Cloudflare Workers)
    - xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed

## Pre-setup
1. Setup and publish your cdn cloudflare worker.
- Some useful references:
  - https://developers.cloudflare.com/workers/get-started/quickstarts/
  - https://developers.cloudflare.com/workers/tutorials/configure-your-cdn/
  - https://egghead.io/courses/introduction-to-cloudflare-workers-5aa3

2. Make sure you have create API token in your cloudflare account with sufficient permissions
- You can have a look at the cloudflare permissions [here](https://developers.cloudflare.com/api/tokens/create/permissions/)
- You should have access to
  - Edit: Worker Routers, DNS

## Usage

```terraform
module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare?ref=v2022.05.26"

  cloudflare_email = "user@gmail.com"
  cloudflare_api_key = var.cloudflare_api_key
  domain = "example.com"
  subject_alternative_names = ["*.example.com"]
  bastion_eip_id = "project-staging-xxxxx.elb.eu-central-1.amazonaws.com"
  nlb_dns_name = "project-staging-xxxxxxx.eu-central-1.elb.amazonaws.com"
  worker_script_name = "serve-cdn"
}
```

