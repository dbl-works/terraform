terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  # optional() with a default in variable types requires 1.3
  required_version = ">= 1.3"
}
