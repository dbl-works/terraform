# Terraform Module: Stack Setup
## Getting Started

This is the pre-setup of stack modules. It will
- create the secrets manager and populate the secrets to AWS
- do domain validation
  - Configure a CNAME record in DNS configuration to establish control of your domain name. This allows ACM to automatically renew DNS-validated certificates before they expire, as long as the DNS record has not changed
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

2. For accessing we need to create a `aws_iam_group` once globally across all projects in one AWS account:

```terraform
resource "aws_iam_group" "engineer" {
  name = "engineer"
  path = "/"
}
```

3. Run `terraform apply`
4. Remove the secrets file from your local machine. Secret should ONLY exist in the secret managers.
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

  # Optional
  add_wildcard_subdomains        = true
  alternative_domains            = []
  is_read_replica_on_same_domain = false # skips cloudflare

  # KMS
  kms_deletion_window_in_days = 30
  eips_nat_count              = 0 # if you need static IPs, set this to the number of AZs. Most likely, you do NOT need static IPs (the resulting NAT adds significant cost to the stack)

  # In case this stack has a read-replica RDS in a different region
  rds_cross_region_kms_key_arn = null
}

# versions.tf

# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_REGION=
provider "aws" {}

# export CLOUDFLARE_API_TOKEN=
provider "cloudflare" {}
```

```terraform
# output.tf

output "app_secrets_arn" {
  value = module.stack-setup.app_secrets_arn
}

output "terraform_secrets_arn" {
  value = module.stack-setup.terraform_secrets_arn
}

output "app_secrets-kms-key" {
  value = module.stack-setup.app_secrets-kms-key
}

output "terraform_secrets-kms-key" {
  value = module.stack-setup.terraform_secrets-kms-key
}

output "kms-key-replica-rds-arn" {
  value = module.stack-setup.kms-key-replica-rds-arn
}

```
