terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.55.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 4.52.1"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "peer"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "cloudflare" {}

module "stack" {
  source = "../.."

  providers = {
    aws           = aws
    aws.peer      = aws.peer
    aws.us-east-1 = aws.us-east-1
  }

  project                     = "validation"
  environment                 = "test"
  domain_name                 = "example.com"
  kms_deletion_window_in_days = 7
  kms_app_arn                 = "arn:aws:kms:eu-central-1:123456789012:key/00000000-0000-0000-0000-000000000000"
  vpc_cidr_block              = "10.0.0.0/16"

  route53domains_dnssec_enabled = true
  alb_mtls_ca_certificates_pem  = "-----BEGIN CERTIFICATE-----\nvalidation-only\n-----END CERTIFICATE-----"
  authenticated_origin_pull = {
    enabled     = true
    certificate = "-----BEGIN CERTIFICATE-----\nvalidation-only\n-----END CERTIFICATE-----"
    private_key = "validation-only-private-key"
  }
}
