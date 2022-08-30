# Fivetran



## Usage

Log into Snowflake, and run the following query:

```
SELECT current_account() as SNOWFLAKE_ACCOUNT_LOCATOR;
```

```terraform
#
# main.tf
#
module "fivetran" {
  source = "github.com/dbl-works/terraform//fivetran?ref=v2021.07.05"

  fivetran_api_key    = var.fivetran_api_key
  fivetran_api_secret = var.fivetran_api_secret
  project             = "my-project"
  environment         = "production"

  destination_user_name        = "${project}-${environment}-bot"
  destination_host             = "${SNOWFLAKE_ACCOUNT_LOCATOR}.eu-central-1.snowflakecomputing.com" # `eu-central-1` if you run on AWS in EU region
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


## Set Up

For access to an AWS RDS we can connect Fivetran via a SSH jump host, e.g. Bastion.

Read the docs: https://fivetran.com/docs/databases/connection-options#sshtunnel

> Fivetran generates a unique public SSH key for each destination. We support multiple connectors on a single SSH tunnel depending on the data volume and network bandwidth

The public key can be copied from the Fivetran dashboard -> Connectors -> RDS -> Settings: Public Key

Store the public key on the SSH host.
If you use the DBL Bastion convention you can upload that key to the Github org's bot account.
This requires the Bot account to be allowlisted for Bastion. You also have to re-deploy bastion.
