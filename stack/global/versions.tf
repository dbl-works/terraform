terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws.us-east-1]
    }
    sentry = {
      source  = "jianyuan/sentry"
      version = ">= 0.11"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.29.0"
    }
  }
  required_version = ">= 1.0"
}
