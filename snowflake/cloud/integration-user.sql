-- creates a read/write user & role to be used e.g. for Fivetran to write data to Snowflake

-- create variables for user / password / role / warehouse / database (needs to be uppercase for objects)
set role_name = 'FIVETRAN_ROLE';
set user_name = 'FIVETRAN_USER';
set user_password = 'YOUR-SECURE-PASSWORD-HERE';
set warehouse_name = 'WH_FIVETRAN';  -- NOTE: should already exist if you use the Snowflake Terraform module
set database_name = 'DB_FIVETRAN'; -- NOTE: if you created multiple databases, you have to adjust this part

-- change role to securityadmin for user / role steps
use role securityadmin;

-- create role for fivetran
create role if not exists identifier($role_name);
grant role identifier($role_name) to role SYSADMIN;

-- grant fivetran role access to warehouse
use role sysadmin;
grant USAGE
on warehouse identifier($warehouse_name)
to role identifier($role_name);
use role securityadmin;

-- create a user for fivetran
create user if not exists identifier($user_name)
password = $user_password
default_role = $role_name
default_warehouse = $warehouse_name;

grant role identifier($role_name) to user identifier($user_name);

-- change role to sysadmin for warehouse / database steps
use role sysadmin;

-- grant fivetran access to database
grant CREATE SCHEMA, MONITOR, USAGE
on database identifier($database_name)
to role identifier($role_name);

-- change role to ACCOUNTADMIN for STORAGE INTEGRATION support (only needed for Snowflake on GCP)
use role ACCOUNTADMIN;
grant CREATE INTEGRATION on account to role identifier($role_name);
use role sysadmin;
