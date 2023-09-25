# Terraform Module: Cloudflare

This module will do the following:

- Route to defaults routes
    - api.my-project.com to the NLB
    - bastion.my-project.com
    - cdn.my-project.com to the S3-Bucket (using Cloudflare Workers)
    - xx.my-project.com to the S3-Bucket (using Cloudflare Workers) for any subdomain needed

## Pre-setup
1. Setup the domain in Cloudflare
2. Setup and publish your CDN cloudflare worker.
- Some useful references:
  - Quickstart: https://developers.cloudflare.com/workers/get-started/quickstarts/
  - Cloudflare CDN tutorials: https://developers.cloudflare.com/workers/tutorials/configure-your-cdn/
  - Introduction to Cloudflare Worker: https://egghead.io/courses/introduction-to-cloudflare-workers-5aa3
  - Cloudflare Router: https://github.com/dbl-works/cloudflare-router

3. Make sure you have created an API token in your Cloudflare account with sufficient permissions
- You can have a look at the cloudflare permissions [here](https://developers.cloudflare.com/api/tokens/create/permissions/)
- You should have access to
  - All zones - Zone:Edit, Workers Routes:Edit, DNS:Edit


```shell
export CLOUDFLARE_API_TOKEN=xxx
```


## Usage

We cannot check if `bastion_public_dns` is present and use that as a condition to set up bastion (or not), since the DNS is unknown at the time of creation.

```terraform
# main.tf

module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare?ref=v2022.05.26"

  domain                 = "example.com"
  alb_dns_name           = "project-staging-xxxxxxx.eu-central-1.elb.amazonaws.com"
  cdn_worker_script_name = "serve-cdn"
  app_worker_script_name = "serve-app"

  # optional
  bastion_enabled    = false # set to true if required
  bastion_public_dns = "project-staging-xxxxx.nlb.eu-central-1.amazonaws.com"
  tls_settings = {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
    always_use_https         = "on"
  }
}
```

```
# versions.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  profile = "dbl-works"
  region  = "eu-central-1"
}

variable "cloudflare_email" {
  type = string # set via: export TF_VAR_cloudflare_email=
}

variable "cloudflare_api_key" {
  type = string # set via: export TF_VAR_cloudflare_api_key=
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}
```
