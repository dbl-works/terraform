# Snowflake Cloud

## Usage

```terraform
# main.tf
module "snowflake_cloud" {
  source = "github.com/dbl-works/terraform//awesome-module?ref=v2022.08.05"

  warehouse_name = "WH_FIVETRAN" # Snowflake mostly uses upcase by their convention

  databases = [
    {
      name                   = "DB_FIVETRAN"
      data_retention_in_days = 0 # 0 days effectively disables Time Travel.
    },
    {
      name                   = "project-A"
      data_retention_in_days = 5 # Enables Time Travel five days into the past.
    },
    {
      name                   = "AWS-datapipline"
      data_retention_in_days = 0 # 0 days effectively disables Time Travel.
    }
  ]

  # optional
  suspend_compute_after_seconds = 57      # on AWS, the minimum charge is 60 seconds
  warehouse_size                = "large" # 8 credits/hour/cluster for "large"
  warehouse_cluster_count       = 1
  # Default value of this variable is the fivetrans IP address in the EU region + using GCP as cloud provider
  # If you are using fivetrans, check the list of IP addresses here: https://fivetran.com/docs/getting-started/ips#euregions
  allowed_ip_list               = ["35.235.32.144/29"]
  blocked_ip_list               = []
}
```

```terraform
# versions.tf
terraform {
  required_providers {
    snowflake = {
      source                = "Snowflake-Labs/snowflake"
      version               = "~> 0.42"
      configuration_aliases = [snowflake.security_admin]
    }
  }
}

# these variables are set via `source .env` which sets environment variables.
variable "snowflake_user" {
  type = string
}

variable "snowflake_private_key_path" {
  type = string
}

variable "snowflake_account" {
  type = string
}

variable "snowflake_region" {
  type = string
}

provider "snowflake" {
  role = "SYSADMIN"

  username = var.snowflake_user # $ export TF_VAR_snowflake_user=<username>
  account  = var.snowflake_account
  region   = var.snowflake_region

  # For auth exactly one option must be set.
  private_key_passphrase = var.snowflake_private_key_path
}

provider "snowflake" {
  role  = "SECURITYADMIN"
  alias = "security_admin"

  username = var.snowflake_user # $ export TF_VAR_snowflake_user=<username>
  account  = var.snowflake_account
  region   = var.snowflake_region

  # For auth exactly one option must be set.
  private_key_passphrase = var.snowflake_private_key_path
}
```


Pricing information:
* https://docs.snowflake.com/en/user-guide/credits.html
* https://www.snowflake.com/blog/how-usage-based-pricing-delivers-a-budget-friendly-cloud-data-warehouse/

> Compute costs are $0.00056 per second for each credit consumed on Snowflake Standard Edition (in the US)

Q: Does Snowflake charge for idle resources?
A: No. Snowflake calculates charges while resources are running. However, you'll want to set up user-defined rules to automate resource suspension, such as "suspend after 3 minutes inactive".

:point-right: on AWS, the first 60 seconds are always billed, after the 61st second, billing is per second.


| Size         | X-Small | Small | Medium | Large | X-Large | 2X-Large | 3X-Large | 4X-Large |
|--------------|---------|-------|--------|-------|---------|----------|----------|----------|
| Credits/hour | 1       | 2     | 4      | 8     | 16      | 32       | 64       | 128      |



## Prerequisites

Sign up for a Snowflake account. Use a generic email address like `snowflake@my-company.com` to decouple the root access from a specific employee's account.

During the "initial set up" a bot account is created with less-than-root-level access for managing the account through terraform.



## Initial Set Up
Create credentials for an **admin** user on Snowflake Cloud used to launch all infrastructure from this module.

You should store the credentials in a secure place, e.g. AWS Secrets, 1Passsord, etc.

```shell
cd ~/.ssh
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_tf_snow_key.p8 -nocrypt
openssl rsa -in snowflake_tf_snow_key.p8 -pubout -out snowflake_tf_snow_key.pub
```

Create a new **worksheet** "deploy-user" in Snowflake and adjust & paste the SQL from this file: `snowflake/cloud/deploy-user.sql` which will create a user with name `TERRAFORM_DEPLOY_BOT` used to manage Snowflake via Terraform.

Create a `.env` file with the following content in your terraform directory:

```shell
# load this file e.g. via "source .env" before running terraform commands

export TF_VAR_snowflake_user="${project}-${environment}-bot"
export TF_VAR_snowflake_private_key_path="~/.ssh/snowflake_tf_snow_key.p8"
export TF_VAR_snowflake_account="SNOWFLAKE_ACCOUNT_LOCATOR"
export TF_VAR_snowflake_region="SNOWFLAKE_REGION_ID"
```


## Post Set Up
**After** you have created the warehouse and databases (i.e. applied this module), create a second user with limited access used for the ETL pipeline e.g. Fivetran.
This user will use **password** authentication. Generate a secure password for that database user.
Then log into Snowflake, go to **worksheets** and create a new worksheet "integration-user".

Adjust and execute the SQL from this script: `snowflake/cloud/integration-user.sql`.


## ToDo
https://quickstarts.snowflake.com/guide/terraforming_snowflake/#0


1 warehouse pro project/client
1 database pro environment/project
FiveTran -> role + warehouse? + database

Snowflake roles/users:
1) terraform/dev role (admin) -> allowlist bastion/vpn
2) 5tran ( read only ) -> allowlist 5tran Cloud IPs
3) Tableau ( read only ) -> allowlist Tableau Cloud IPs


5tran via terraform
=> create users that assume these roles
add 5tran -> must have access to Snowlake ( SSH credentials + endpoint )


=> Google Analytics via terraform
