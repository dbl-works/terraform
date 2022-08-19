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
  project                  = "facebook"
  environment              = "production"
  cluster_name             = "project-cluster"
  database_name            = "project-database"
  alb_arn_suffix           = "app/project/123456789"
  elasticache_cluster_name = "project-elasticache"

  # optional
  dashboard_name           = "facebook"
  metric_period            = 60
  alarm_period             = 120
  alarm_evaluation_periods = 1
  slack_channel_id         = "CXXXXXXXXXX" # Required if user want to enable slack notification
  slack_workspace_id       = "TXXXXXXXX" # Required if user want to enable slack notification
}
```
