-- creates user & role with wide-ranged administrative rights to be used e.g. for Terraform to create resources on Snowflake

-- role & user for administrative purposes
CREATE USER "TERRAFORM_DEPLOY_BOT" RSA_PUBLIC_KEY='YOUR-PUBLIC-KEY-HERE' DEFAULT_ROLE=PUBLIC MUST_CHANGE_PASSWORD=FALSE;

GRANT ROLE SYSADMIN TO USER "TERRAFORM_DEPLOY_BOT";
GRANT ROLE SECURITYADMIN TO USER "TERRAFORM_DEPLOY_BOT";

-- take note of the output of this query
SELECT current_account() as SNOWFLAKE_ACCOUNT_LOCATOR, current_region() as SNOWFLAKE_REGION_ID;
