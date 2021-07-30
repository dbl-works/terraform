#
# https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly
#
# we need to be able to pass in a different provider to create certificates in different regions
# more specific in us-east-1 for the CloudFront distribution
#
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.41"
      configuration_aliases = var.configuration_aliases
    }
  }
}
