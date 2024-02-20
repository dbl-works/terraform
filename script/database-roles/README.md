# Terraform Module: DB SQL Script - Create readonly role

Run SQL script in DB to create DB role(s).
This script will be run on the machine which run this TF script. It assumes bastion host have been setup and your SSH keys is allowed in the bastion host.

## Usage

on AWS you can extract the DB information programmatically:

```terraform
data "aws_db_instance" "main" {
  db_instance_identifier = var.db_identifier
}

data "aws_secretsmanager_secret_version" "infra" {
  secret_id = "${var.project}/infra/${var.environment}"
}

locals {
  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.infra.secret_string
  )
}
```

```terraform
module "database_roles_scripts" {
  source = "github.com/dbl-works/terraform//script/database-roles?ref=v2023.03.06"

  project       = local.project
  environment   = local.environment
  domain_name   = "example.com"
  db_identifier = "unique_db_name"

  # see above, this is an example for AWS
  db_username      = local.credentials.db_username
  db_root_password = local.credentials.db_root_password
  db_endpoint      = data.aws_db_instance.main.endpoint
  db_name          = data.aws_db_instance.main.db_name

  # Optional
  bastion_subdomain = "bastion-staging"
}
```
