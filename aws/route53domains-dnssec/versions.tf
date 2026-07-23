terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws_route53domains_delegation_signer_record was added in 5.34
      version = ">= 5.34"
    }
  }
  # mock_provider in tests/ requires Terraform 1.7
  required_version = ">= 1.7"
}
