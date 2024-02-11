terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    fivetran = {
      source  = "fivetran/fivetran"
      version = "~> 1.0"
    }
  }

  required_version = ">= 1.0"
}
