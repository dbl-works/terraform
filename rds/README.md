# Terraform Module: RDS

Used for creating and configuring databases and their networking.


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


## Temporary password for read-only users
If the database is set up to use IAM user role based authentication, password have to be generated via the AWS cli and are only valid for 15min.

You can use the following bash script, which relies on being executed inside the terraform workspace folder, since it reads the database URL from the terraform state.

```bash
#
# params:
#   $1: name of the AWS profile, optional, defaults to "default"
#   $2: name of the user role, optional, defaults to "readonly"
#
# example usage: rdspw aws-profile-1
#
generate_rds_password () {
  database_url_with_port=$(terraform output database_url |  tr -d '"')
  database_url="${database_url_with_port%%:*}"
  database_port=${database_url_with_port##*:}

  # convention for folder: terraform/workspaces/project-environment => get the "project-environment" part
  current_folder_name="${PWD##*/}"

  # convention for DB username: project_environment_readonly => we want to assemble this from the folder name
  database_username="$(echo $current_folder_name | tr - _)_${2:-readonly}"

  # ${1:-50}: first argument or "default".
  AWS_PROFILE="${1:-default}" aws rds generate-db-auth-token --hostname "$database_url" --port "$database_port" --region eu-central-1 --username "$database_username"
}
alias rdspw=generate_rds_password
```
