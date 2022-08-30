# Snowflake Cloud

## Usage

```terraform
module "snowflake_cloud" {
  source = "github.com/dbl-works/terraform//awesome-module?ref=v2022.08.05"

  account_name = "dbl-works" # e.g. the project or company name.

  databases = [
    {
      name                   = "project-A"
      data_retention_in_days = 0 # 0 days effectively disables Time Travel.
    },
    {
      name                   = "AWS-datapipline"
      data_retention_in_days = 0 # 0 days effectively disables Time Travel.
    },
    {
      name                   = "Fivetran"
      data_retention_in_days = 5 # Enables Time Travel five days into the past.
    }
  ]

  # optional
  suspend_compute_after_seconds = 57      # on AWS, the minimum charge is 60 seconds
  warehouse_size                = "large" # 8 credits/hour/cluster for "large"
  warehouse_cluster_count       = 1
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
Create credentials for an admin user on Snowflake Cloud used to launch all infrastructure from this module.

You should store the credentials in a secure place, e.g. AWS Secrets, 1Passsord, etc.

```shell
cd ~/.ssh
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_tf_snow_key.p8 -nocrypt
openssl rsa -in snowflake_tf_snow_key.p8 -pubout -out snowflake_tf_snow_key.pub
```

Log into Snowflake, go to **worksheets** and create a new worksheet.
You can save the new worksheet e.g. as `create ${project}-${environment}-bot`.

Paste, adjust, and execute the following SQL:

```sql
-- role & user for administrative purposes
CREATE USER "${project}-${environment}-bot" RSA_PUBLIC_KEY='RSA_PUBLIC_KEY_HERE' DEFAULT_ROLE=PUBLIC MUST_CHANGE_PASSWORD=FALSE;

GRANT ROLE SYSADMIN TO USER "${project}-${environment}-bot";
GRANT ROLE SECURITYADMIN TO USER "${project}-${environment}-bot";

-- role & user for external tools with read-only access ( e.g. Tableau )
CREATE USER "${project}-${environment}-readonly" PASSWORD='A_SECURE_PASSWORD_HERE' DEFAULT_ROLE=PUBLIC  MUST_CHANGE_PASSWORD=FALSE;

GRAND USAGE ON WAREHOUSE "" TO ROLE

-- take note of the return value
SELECT current_account() as SNOWFLAKE_ACCOUNT_LOCATOR, current_region() as SNOWFLAKE_REGION_ID;
```

Create a `.env` file with the following content in your terraform directory:

```shell
# load this file e.g. via "source .env" before running terraform commands

export TF_VAR_snowflake_user="${project}-${environment}-bot"
export TF_VAR_snowflake_private_key_path="~/.ssh/snowflake_tf_snow_key.p8"
export TF_VAR_snowflake_account="SNOWFLAKE_ACCOUNT_LOCATOR"
export TF_VAR_snowflake_region="SNOWFLAKE_REGION_ID"
```



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
