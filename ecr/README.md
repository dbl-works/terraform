# Terraform Module: ECR Repository

A repository for storing built docker images.



## Usage

```terraform
module "ecr" {
  source = "github.com/dbl-works/terraform//ecr?ref=v2021.07.05"

  project = local.project

  # Optional
  mutable = false
  valid_days = 3
  ecr_lifecycle_policy_rules = [
    {
      "rulePriority": 2,
      "description": "Keep last 30 images",
      "selection": {
          "tagStatus": "tagged",
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
