# Terraform Module: DB SQL Script - Create readonly role

Run SQL script in DB to create DB role(s).
This script will be run on the machine which run this TF script.

## Usage

```terraform
module "db_readonly_script" {
  source = "github.com/dbl-works/terraform//script/database_role?ref=v2023.03.06"

  project = local.project
  environment = local.environment
  domain_name = "example.com"
  db_identifier = "unique_db_name"

  # Optional
  bastion_subdomain = "bastion-staging"
}
```
