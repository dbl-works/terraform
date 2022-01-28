# Terraform Module: RDS

Used for creating and configuring databases and their networking.

Will create an initial database named `{project}_{environment}`.


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
  instance_class      = "db.t3.micro"
  engine_version      = "13.2"
  publicly_accessible = false
  allocated_storage   = 100
  multi_az            = false
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
