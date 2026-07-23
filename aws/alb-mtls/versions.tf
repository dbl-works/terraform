terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_lb_trust_store was added in 5.30; kept consistent with the ecs and route53domains-dnssec modules
      version = ">= 5.34"
    }
  }
  required_version = ">= 1.0"
}
