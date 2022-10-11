-- creates a read-only user & role to be used e.g. for Tableau/Metabase/Grafana to read data from Snowflake

-- create variables for user / password / role / warehouse / database (needs to be uppercase for objects)
set role_name = 'READONLY_ROLE';
set user_name = 'READONLY_USER';
set user_password = 'YOUR-SECURE-PASSWORD-HERE';
set warehouse_name = 'WH_FIVETRAN';  -- NOTE: should already exist if you use the Snowflake Terraform module
set database_name = 'DB_FIVETRAN'; -- NOTE: if you created multiple databases, you have to adjust this part

-- change role to securityadmin for user / role steps
use role securityadmin;


-- create role for fivetran
create role if not exists identifier($role_name);
grant role identifier($role_name) to role SYSADMIN;

--
-- only necessary if the DB already existed before
--
grant select on future tables in database identifier($database_name) to role identifier($role_name);
grant select on all tables in database identifier($database_name) to role identifier($role_name);

grant usage, monitor on database identifier($database_name) to role identifier($role_name);
grant usage, monitor on all schemas in database identifier($database_name) to role identifier($role_name);

-- create a user for fivetran
create user if not exists identifier($user_name)
password = $user_password
default_role = $role_name
default_warehouse = $warehouse_name;

grant role identifier($role_name) to user identifier($user_name);

-- change role to sysadmin for warehouse / database steps
use role sysadmin;

-- grant fivetran role access to warehouse
grant USAGE
on warehouse identifier($warehouse_name)
to role identifier($role_name);
