# Terraform Module: Cloudflare Zone

This module will do the following:

- Create the default DNS records
    - `api.my-project.com` to the ALB, proxied
    - `bastion.my-project.com` to `bastion_public_dns`, not proxied. Optional and rarely needed. Set `bastion_enabled` to use it for SSH traffic through an NLB
    - One record for each key in `s3_cloudflare_records`, proxied to the S3 bucket through a Cloudflare worker

## Pre-setup
1. Setup the domain in Cloudflare
2. Setup and publish your CDN cloudflare worker.
- Some useful references:
  - Quickstart: https://developers.cloudflare.com/workers/get-started/quickstarts/
  - Cloudflare CDN tutorials: https://developers.cloudflare.com/workers/tutorials/configure-your-cdn/
  - Cloudflare Router: https://github.com/dbl-works/cloudflare-router

3. Make sure you have created an API token in your Cloudflare account with sufficient permissions
- You can have a look at the cloudflare permissions [here](https://developers.cloudflare.com/api/tokens/create/permissions/)
- You should have access to
  - All zones - Zone:Edit, Workers Routes:Edit, DNS:Edit


```shell
export CLOUDFLARE_API_TOKEN=xxx
```


## Usage

`bastion_enabled` is a separate flag. `count` cannot depend on `bastion_public_dns`, because Terraform does not know that value until apply.

```terraform
# main.tf

module "cloudflare" {
  source = "github.com/dbl-works/terraform//cloudflare/zone?ref=v2026.09.05"

  domain       = "example.com"
  alb_dns_name = "project-staging-xxxxxxx.eu-central-1.elb.amazonaws.com"

  s3_cloudflare_records = {
    cdn = {
      worker_script_name = "serve-cdn"
    }
    app = {
      worker_script_name = "serve-app"
    }
  }

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

## Authenticated Origin Pulls

`authenticated_origin_pull` uploads a custom zone-level client certificate and enables Cloudflare to present it to an mTLS origin:

```terraform
authenticated_origin_pull = {
  enabled     = true
  certificate = file("${path.root}/certificates/cloudflare-aop-client.crt")
  private_key = file("${path.root}/certificates/cloudflare-aop-client.key")
}
```

The origin must trust the CA that signed this leaf certificate. Do not upload the CA private key to Cloudflare or the ALB trust store. Store the encrypted key in the restricted Terraform Secrets Manager vault; see the [ALB mTLS documentation](../../aws/alb-mtls/README.md#upload-without-storing-the-values-in-terraform-state) for a write-only Terraform setup that omits it from state.

The Cloudflare provider stores the client private key in Terraform state even though Terraform masks the value in normal output. Use an encrypted remote backend with tightly restricted access.

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
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3"
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
