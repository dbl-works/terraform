# Fivetran



## Usage

```terraform
#
# main.tf
#
module "fivetran" {
  source = "/Users/lr/Sites/dbl-works/terraform/fivetran"

  fivetran_api_key    = var.fivetran_api_key
  fivetran_api_secret = var.fivetran_api_secret
  project             = "my-project"
  environment         = "production"

  destination_user_name        = "${project}-${environment}-bot"
  destination_host             = "XXX.eu-central-1.privatelink.snowflakecomputing.com"
  destination_connection_type  = "Directly"
  destination_password         = "XXX"
  destination_database_name    = "${project}-${environment}"
}

#
# versions.tf
#
terraform {
  required_providers {
    fivetran = {
      source  = "fivetran/fivetran"
      version = "~> 0.6.1"
    }
  }
}

# if kept in e.g. a `.env` file, run `source .env` before running terraform commands
variable "fivetran_api_key" {
  type = string
}

variable "fivetran_api_secret" {
  type = string
}

provider "fivetran" {
  api_key    = var.fivetran_api_key    # $ export TF_VAR_fivetran_api_key=<api-key>
  api_secret = var.fivetran_api_secret # $ export TF_VAR_fivetran_api_secret=<api-secret>
}
```

```shell
# .env

export TF_VAR_fivetran_api_key=xxx
export TF_VAR_fivetran_api_secret=xxx
```
