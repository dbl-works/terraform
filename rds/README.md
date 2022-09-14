# Terraform Module: RDS

Used for creating and configuring databases and their networking.

Will create an initial database named `{project}_{environment}`.


:warning: If you create a read replica in another VPC you need a [VPC-Peering-Resource](vpc-peering/README.md).


## Usage

```terraform
module "db" {
  source = "github.com/dbl-works/terraform//rds?ref=v2021.07.01"

  account_id                 = "12345678"
  region                     = "eu-central-1"
  vpc_id                     = "vpc-123"
  project                    = "someproject"
  environment                = "staging"
  password                   = "xxx"
  kms_key_arn                = "arn:aws:kms:eu-central-1:12345678:key/xxx-xxx"
  subnet_ids                 = ["subnet-1", "subnet-2"]
  allow_from_security_groups = [module.ecs.ecs_security_group_id]

  # optional
  instance_class         = "db.t3.micro"
  engine_version         = "13"
  publicly_accessible    = false
  allocated_storage      = 100
  multi_az               = false
  regional               = false # set to `true` to append region to name, unless name given
  name                   = null # defaults to "${var.project}-${var.environment}", may need to be unique per region
  snapshot_identifier    = "" # crate from snapshot
  allow_from_cidr_blocks = []

  # when creating a read-replica
  master_db_instance_arn = null  # ARN of the master database
  is_read_replica        = false # if true, this will be a read-replica
  enable_replication     = false # if true, logical replication will be enabled
}
```



## RDS Engine Versions

To get a list of RDS versions, you can use the following command:

```shell
aws rds describe-db-engine-versions --engine postgres --engine-version 13 --region us-east-1 --endpoint https://rds.us-east-1.amazonaws.com --output text --query 'DBEngineVersions[*].{Engine:Engine,EngineVersion:EngineVersion}'
```



## Temporary password for AWS IAM role-based access

### Attach correct roles to IAM user

Attach the following roles to your IAM user:

```terraform
"${project}-${environment}-rds-db-connect-readonly"
"${project}-${environment}-rds-view"
```



### Generate password in the console

If the database is set up to use IAM user role based authentication, a password has to be generated via the AWS cli. This passworde is valid for 15min.

You can use the following bash script, which relies on being executed inside the terraform workspace folder, since it reads the database URL from the terraform state.

```bash
#
# params:
#   $1: project name, e.g. "myproject"
#   $2: project environment, e.g. "staging"
#   $3: name of the AWS profile, optional, defaults to "default", won't be set if `AWS_PROFILE` is already set
#   $4: name of the user role, optional, defaults to "readonly"
#
# example usage: generate_rds_password myproject staging aws-profile-1
# for the lazy ones: shortcut the function name to "rdspw"
#
function generate_rds_password () {
  PROJECT="$1" # project name, e.g. "myproject"
  ENVIRONMENT="$2" # environment name, e.g. "staging"

  TERRAFORM_DIR="terraform/workspaces/$PROJECT-$ENVIRONMENT" # terraform folder convention
  declare DATABASE_URL_WITH_PORT

  CURRENT_DIR="$PWD"
  if [[ "$CURRENT_DIR" == *"$TERRAFORM_DIR" ]]
  then
    DATABASE_URL_WITH_PORT=$(terraform output database_url |  tr -d '"')
  else
    cd "$TERRAFORM_DIR" || exit
    DATABASE_URL_WITH_PORT=$(terraform output database_url |  tr -d '"')
    cd "$CURRENT_DIR" || exit
  fi

  DATABASE_URL=${DATABASE_URL_WITH_PORT%%:*}
  DATABASE_PORT=${DATABASE_URL_WITH_PORT##*:}

  # convention for DB username: project_environment_readonly, e.g. myproject_staging_readonly
  DATABASE_USERNAME="$PROJECT"_"$ENVIRONMENT"_"${4:-readonly}"

  if [[ -z "$AWS_PROFILE" ]]
  then
    # ${3:-default}: evaluates to 3rd argument or the literal string "default"
    export AWS_PROFILE="${3:-default}"
  fi

  aws rds generate-db-auth-token --hostname "$DATABASE_URL" --port "$DATABASE_PORT" --region eu-central-1 --username "$DATABASE_USERNAME"
}
alias rdspw=generate_rds_password
```
## Enable DB replication for BI

Some projects connect RDS directly to Fivetran for BI. Here are instructions how to setup the DB in order to be able to connect from Fivetran connector.

### AWS RDS Postgres connector

NOTE: All DB operations should first be tested on staging.

We need to create a separate DB role that is used from Fivetran to access the data. We must limit te access to only required data and not including any sensitive info like names, codes,... The following script can be used to create a role and also assign all required permissions. `allowed_tables` can be used if whole tables should be available. When some columns contain sensitive info, we can use per column permissions template included in script.

The user under which the script is being executed must have permissions to create a new database role. If the rails application DB user does not have that permission, a root DB user will be needed. For some of the projects the credentials can be found in AWS Secrets Manager / terraform (admins only). The following SQL can be used to check role permissions:

```SQL
SELECT
  r.rolname,
  r.rolsuper,
  r.rolinherit,
  r.rolcreaterole,
  r.rolcreatedb,
  r.rolcanlogin,
  r.rolconnlimit,
  r.rolvaliduntil,
  r.rolreplication,
  r.rolbypassrls,
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) AS memberof
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_'
ORDER BY 1;
```

Adjust and use the following script to add permissions:

```SQL
DO $body$
DECLARE
  project varchar := '';
  environment varchar := 'staging';
  -- password should be 22 characters, store it to DBL 1pass shared vault
  password varchar := '';
  -- tables that should be accessible in full (all columns)
  allowed_tables varchar[] := array[
    'table1',
  ];
  -- this is not the same for all applications, check it
  database_name varchar := project || '_' || environment;

  table_name varchar;
BEGIN
  EXECUTE format('CREATE ROLE %s_%s_fivetran NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;', project, environment);
  EXECUTE format('ALTER ROLE %s_%s_fivetran WITH LOGIN ENCRYPTED PASSWORD ''%s'';', project, environment, password);
  EXECUTE format('GRANT CONNECT ON DATABASE %s TO %s_%s_fivetran;', database_name, project, environment);
  EXECUTE format('GRANT USAGE ON SCHEMA public TO %s_%s_fivetran;', project, environment);

  -- add permissions for tables listed above
  FOREACH table_name IN ARRAY allowed_tables
  LOOP
    EXECUTE format('GRANT SELECT ON TABLE %s TO %s_%s_fivetran;', table_name, project, environment);
  END LOOP;

  -- template for adding per column permissions, please note the xmin column at the end (neded whyn you use XMIN)
  EXECUTE format('GRANT SELECT (id, ..., xmin) on <table_name> to %s_%s_fivetran;', project, environment);
END
$body$
```

#### XMIN

XMIN is not suitable for large databases. It does not detect deletes.

There is no additional setup required.

#### Logical replication using WAL / test_decoding plugin

We need to create a replication slot to enable usage of `test_decoding` plugin:

1. Set enable_replication = true in RDS terraform
```terraform
module "rds" {
  source = "github.com/dbl-works/terraform//rds?ref=x"
  ...
  enable_replication = true
}
```
2. Apply with: `tf apply`
3. Manually restart the DB via AWS console to apply static parameters. Please note that DB will be offline for some time (should be minutes), so this is best executed during low traffic.
4. You can check state of replication with:
```SQL
SHOW rds.logical_replication;
```
5. Create replication slot by executing following SQL as user with supervisor privileges:
```SQL
SELECT pg_create_logical_replication_slot('fivetran_replication_slot', 'test_decoding');
GRANT rds_replication TO <fivetran_db_username>;
```
6. Check if slot is available (it may take some time for entries to appear)
```SQL
SELECT count(*) FROM pg_logical_slot_peek_changes('fivetran_replication_slot', null, null);
```

NOTE: After you create the slot it has to be used by Fivetran. Otherwise the WAL data will accumulate and take all available DB space. Once DB is full, it is not usable!

#### AWS security policy

If the database in publicly accessible, it may be protected by inbound rules. To allow Fivetran access to the DB, please whitelist [Fivetran IPs](https://fivetran.com/docs/getting-started/ips). Our Fivetran is [hosted in zone](https://fivetran.com/dashboard/warehouse) `europe-west3 (Frankfurt)`, so we need to whitelist:
```
35.235.32.144/29
```
#### SSH tunneling

If the application DB is behind bastion, an SSH tunnel has to be configured to allow access:

1. Bastion URL is the same you use to access the database.
2. Please read how to setup bastion with public key [here](https://github.com/dbl-works/terraform/pull/118/files#diff-94cb490f08aaef66dedfd461d69ed21f92555c728a81212e41accf096b31c118)

Check [Modifly connector](https://fivetran.com/integrations/postgres_rds/?name=modifly&groupId=plausible_comprise) for example.
