# Terraform Module: Github Backup

Backup all repositories in an organization to an S3 bucket.

This creates a lambda function that is triggered by a CloudWatch event.

A SecretsManager secret is created to store the Github token; you must manually add the Github token to the secret after creation. The key-name must be `github_token`.

## Usage

```terraform
module "github-backup" {
  source = "github.com/dbl-works/terraform//github-backup?ref=v2021.07.05"

  github_organization = "dbl-works"
  s3_bucket_name      = "dbl-works-github-backup"

  # optional
  interval_value = 1
  interval_unit  = "hours"
}
```
