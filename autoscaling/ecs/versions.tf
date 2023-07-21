terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  # We need the optional attributes for this module
  # https://github.com/hashicorp/terraform/releases/tag/v1.3.0
  required_version = "~> 1.3"
}
