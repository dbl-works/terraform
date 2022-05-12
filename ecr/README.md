# Terraform Module: ECR Repository

A repository for storing built docker images.


## Usage

```terraform
module "ecr" {
  source = "github.com/dbl-works/terraform//ecr?ref=v2021.07.05"

  project = local.project

  # Optional
  mutable = false
}
```
