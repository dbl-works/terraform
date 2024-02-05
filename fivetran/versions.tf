terraform {
  required_providers {
    fivetran = {
      source  = "fivetran/fivetran"
      version = "~> 1.0"
    }
  }

  required_version = "~> 1.3"
}

# Can be set by FIVETRAN_APIKEY
variable "fivetran_api_key" {
  type = string
}

# Can be set by FIVETRAN_APISECRET
variable "fivetran_api_secret" {
  type = string
}

provider "fivetran" {
  api_key    = var.fivetran_api_key    # $ export TF_VAR_fivetran_api_key=<api-key>
  api_secret = var.fivetran_api_secret # $ export TF_VAR_fivetran_api_secret=<api-secret>
}
