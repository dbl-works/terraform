# Terraform Module: Cloudwatch

Create a cloudwatch dashboard that consist of the following resources' metrics:
1. ECS Cluster
2. Database
3. Elasticache

## Usage

```terraform
module "cloudwatch" {
  source = "github.com/dbl-works/terraform//cloudwatch?ref=v2021.07.05"

  # Required
  region                   = "eu-central-1"
  dashboard_name           = "facebook"
  cluster_name             = "project-cluster"
  database_name            = "project-database"
  alb_arn_suffix           = "app/project/123456789"
  elasticache_cluster_name = "project-elasticache"

  # optional
  period = 60
}
```
