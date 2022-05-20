# Terraform Module: Stack Setup
## Getting Started

This is the pre-setup of stack modules. It will create the secrets manager and populate the secrets to AWS.
It should only be run once prior to the creation of stack modules.

1. To populate secrets to the secret manager, you'll need to prepare 2 json files
   - app-secrets.json (For applications to use inside containers)
     - RAILS_MASTER_KEY
     - SIDEKIQ_USER
     - SIDEKIQ_PASS
     - REDIS_URL (Can leave blank until getting the info from the terraform output of stack module)
     - DATABASE_URL (Can leave blank until getting the info from the terraform output of stack module)

   - terraform-secrets.json (Stores secrets for use in terraform workspace)
     - db_root_password
     - db_username

2. Run `terraform apply`
3. Remove the secrets file from your local machine. Secret should ONLY exist in the secret managers.


```terraform
module "stack-setup" {
  source = "github.com/dbl-works/terraform//stack/setup?ref=v2022.05.18"

  project            = "someproject"
  environment        = "staging"

  # Optional
  # KMS
  kms_deletion_window_in_days = 30
}
