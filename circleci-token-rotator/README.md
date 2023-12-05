# Terraform Module: Rotate CircleCI Secrets

Rotates IAM user's AWS Access Keys on CircleCI.

## Usage

```terraform
module "ecr" {
  source = "github.com/dbl-works/terraform//circleci-token-rotator"

  project = "facebook"
  circle_ci_organization_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Optional
  context_name = "facebook-aws"
  user_name    = "deploy-bot"
  token_rotation_interval_days = 183
  timeout = 900
  memory_size = 128
}
```
