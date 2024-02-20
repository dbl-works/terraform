# Terraform Module: IAM - ECS Scaling

AWS IAM Role for ECS Scaling

This role is needed for autoscaling/ecs

## Usage


```
module "iam_role_for_ecs_scaling" {
  source = "github.com/dbl-works/terraform//iam/iam-policy-for-ecs-scaling?ref=v2022.05.18"
}
```
