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
  custom_metrics           = [
    {
      "height" : 4,
      "width" : 4,
      "type" : "metric",
      "properties" : {
        "title" : "Average Response Time",
        "view" : "singleValue",
        "sparkline" : true,
        "metrics" : [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/project/123456789", { "label" : "app/project/123456789" }]
        ],
        "region" : "eu-central-1"
      }
    }
  ]
  dashboard_name           = "facebook"
  metric_period            = 60
  alarm_period             = 120
  alarm_evaluation_periods = 1

  sns_topic_arns           = ["arn:aws:sns:eu-central-1:1XXXXXXXXXXX:first-sns-topic"] # Required if user want to publish message to the SNS when alarm is in alarm state
}
```
