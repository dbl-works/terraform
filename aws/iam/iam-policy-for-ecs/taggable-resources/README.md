# Terraform Module: IAM Policy for ECS - Taggable Resources

List of ECS related policy that is consist of taggable resources.
Either project_name and project_tag needs to be present.

- When `project_name` is present, access will be given to the resources with `Project` tags equals to the `project_name` value
- When `project_tag` is present, access will be given to the resources with `Project` tags similar to that principal project tag

## Usage

```terraform
module "iam_ecs_taggable_resources" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-policy-for-ecs/taggable-resources?ref=main"

  region       = "eu-central-1"
  environment  = "staging"

  # Optional
  project_name = "facebook"
  project_tag  = "staging-developer-access-projects"
}

output "policy_json" {
  value = module.iam_ecs_taggable_resources.policy_json
}
```
