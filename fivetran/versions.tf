terraform {
  required_providers {
    fivetran = {
      source  = "fivetran/terraform-provider-fivetran"
      version = "~> 0.6.1"
    }
  }
}

provider "fivetran" {
  api_key    = var.fivetran_api_key    # $ export TF_VAR_fivetran_api_key=<api-key>
  api_secret = var.fivetran_api_secret # $ export TF_VAR_fivetran_api_secret=<api-secret>
}
