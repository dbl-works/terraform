terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    aws = {
      source = "hashicorp/aws"
      # the aurora child module requires 6.x; all other child modules need >= 5.34 or lower
      version = ">= 6.0"
      # Route 53 Domains only exposes its domain-registration API in us-east-1.
      configuration_aliases = [aws.peer, aws.us-east-1]
    }
  }
  required_version = ">= 1.0"
}
