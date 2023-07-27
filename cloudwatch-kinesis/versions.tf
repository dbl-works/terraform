terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Some of the configuration (i.e. s3) is deprecated in version 5
      version = ">= 4.0, < 5"
    }
  }
  required_version = ">= 1.0"
}
