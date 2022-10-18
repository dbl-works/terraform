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
data "aws_region" "current" {}

module "fivetran" {
  source = "github.com/dbl-works/terraform//fivetran?ref=v2021.07.05"

  fivetran_api_key    = var.fivetran_api_key
  fivetran_api_secret = var.fivetran_api_secret
  project             = "my-project"
  environment         = "production"

  destination_user_name        = "FIVETRAN_USER"
  destination_role_arn         = "FIVETRAN_ROLE"
  destination_host             = "${SNOWFLAKE_ACCOUNT_LOCATOR}.eu-central-1.snowflakecomputing.com" # `eu-central-1` if you run on AWS in EU region
  destination_connection_type  = "Directly"
  destination_password         = "XXX"
  destination_database_name    = "${project}-${environment}"

  # Sources
  ## Github
  sources_github = [
    {
      organisation = "facebook"
      sync_mode    = "SpecificRepositories"
      repositories = ["facebook/react"]
      username     = "dbl-bot"
      pat          = var.github_pat
    }
  ]

  ## lambda
  sources_lambda = [
    service_name           = "cloudwatch_metrics"
    project                = "react"
    environment            = "staging"
    lambda_source_dir      = "${path.module}/tracker"
    lambda_output_path     = "${path.module}/dist/tracker.zip"
    ## NOTES: Fivetran connector needs this value to know which aws region code that lambda is deployed from
    ## If you would like to deploy the lambda connector to region other than the default aws region, please refer
    ## to the example below.
    aws_region_code        = data.aws_region.current.name
    policy_arns_for_lambda = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]
    script_env             = {
      RESOURCES_DATA = {
        projectName      = "facebook"
        serviceName      = "web",
        clusterName      = "facebook-staging"
        loadBalancerName = "app/facebook-staging/a1c2a365faf11127"
        environment      = "staging"
      },
      PERIOD         = "3600"
    }
  ]

  lambda_settings = {
    lambda_role_arn = "arn:aws:iam::123456789:role/fivetran_lambda" # optional
    lambda_role_name = "fivetran_lambda" # optional
    fivetran_aws_account_id ="834469178297" # optional
  } # optional
}

#
# multi-region-lambda.tf
#

## Multi region lambdas have to be created by the fivetran lambda module
## because terraform currently doesn't support the feature of instantiating multiple provider by loop
## https://github.com/hashicorp/terraform/issues/19932
module "fivetran_lambda" {
  source = "github.com/dbl-works/terraform//fivetran/connectors/lambda?ref=v2022.07.05"

  providers = {
    fivetran = fivetran
    aws      = aws.sa-east-1
  }

  fivetran_group_id = "plausible_ansible" # Also know as external_id. Understand the group concept here: https://fivetran.com/docs/getting-started/powered-by-fivetran#createagroupusingtheui
  project           = "test"              # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  environment       = "staging"           # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)

  # optional
  service_name       = "lambda"                                         # connector name shown on Fivetran UI, i.e. (service_name)_(project)_(env)_(aws_region_code)
  aws_region_code    = "sa-east-1"
  lambda_role_arn    = "arn:aws:iam::175743622168:role/fivetran_lambda" # Lambda role created for connecting the fivetran and lambda. Reuse the same role if you already have it created.
  lambda_source_dir  = "${path.module}/cloudwatch_metrics"
  lambda_output_path = "${path.module}/dist/cloudwatch_metrics.zip"

  script_env             = {
    RESOURCES_DATA = {
      projectName      = "facebook"
      serviceName      = "web",
      clusterName      = "facebook-staging"
      loadBalancerName = "app/facebook-staging/a1c2a365faf11127"
      environment      = "staging"
    },
    PERIOD         = "3600"
  }
}

provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
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

By default **all** tables and columns are synced. The following script allows to alter this behavior:

```terraform
resource "fivetran_connector_schema_config" "schema" {
  connector_id = module.fivetran.fivetran_connector.rds.id # the ID of the connector whose standard config is managed by the resource

  # all schemas, tables and columns are ENABLED by default.
  schema_change_handling = "ALLOW_ALL"

  # explicitly specify DISABLED items or hashed tables
  schema {
    name = var.schema_name
    table {
      name = "table_name"
      column {
        name   = "hashed_column_name"
        hashed = "true"
      }
      column {
        name    = "blocked_column_name"
        enabled = "false"
      }
    }
    table {
      name    = "blocked_table_name"
      enabled = "false"
    }
  }
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
