# Terraform Module: ECR Repository

A repository for storing built docker images.


## Usage

```terraform
module "ecr" {
  source = "github.com/dbl-works/terraform//ecr?ref=v2021.07.05"

  project = local.project

  # Optional
  mutable = false # Set mutable to true when using protected tags, so tags like `latest-main` can be overwritten
  valid_days = 3
  protected_tags = ["latest-main", "latest-production"] # will keep at least 1 of this tag
  ecr_lifecycle_policy_rules = [
    {
      "rulePriority": 4,
      "description": "Keep last 30 images",
      "selection": {
          "tagStatus": "untagged",
          "tagPrefixList": ["v"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
      },
      "action": {
          "type": "expire"
      }
    }
  ]
}
```
