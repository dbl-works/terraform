terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      # cloudflare_zero_trust_access_* resources exist from 4.40 onwards
      version = "~> 4.40"
    }
  }
  required_version = ">= 1.3"
}
