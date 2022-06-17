# Terraform Module: Stack Setup
## Getting Started

This is the pre-setup of stack modules. It will create the secrets manager and populate the secrets to AWS.
It should only be run once prior to the creation of stack modules.

1. To populate secrets to the secret manager, you'll need to prepare 2 json files
   - app-secrets.json (For applications to use inside containers)
     - RAILS_MASTER_KEY
     - SIDEKIQ_USER
     - SIDEKIQ_PASS
     - REDIS_URL (Update the value in the AWS console after getting the value from stack module's output)
     - DATABASE_URL (Update the value in the AWS console after getting the value from stack module's output)

   - terraform-secrets.json (Stores secrets for use in terraform workspace)
     - db_root_password
     - db_username

2. Run `terraform apply`
3. Remove the secrets file from your local machine. Secret should ONLY exist in the secret managers.
When commit the changes, exclude the json file from the commit history.
You can avoid this by adding the file to .gitignore

```
echo "**/app-secrets.json" >> .gitignore
echo "**/terraform-secrets.json" >> .gitignore
```


```terraform
module "stack-setup" {
  source = "github.com/dbl-works/terraform//stack/setup?ref=v2022.05.18"

  project            = "someproject"
  environment        = "staging"
  domain             = "example.com"
  add_wildcard_subdomains = true
  subject_alternative_names = ["*.example.com"]

  # Optional
  # KMS
  kms_deletion_window_in_days = 30
}
```

```terraform
# output.tf

output "app_secrets_arn" {
  value = module.stack-setup.app_secrets_arn
}

output "terraform_secrets_arn" {
  value = module.stack-setup.terraform_secrets_arn
}
```
