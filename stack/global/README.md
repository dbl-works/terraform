# Terraform Module: Stack / Global

This launches resources required only once per Project. It includes the following resources:

- AWS Global Load Balancer (optional)
- IAM roles required only once, such as deploy-bot, role for auto-scaling, etc.
- Billing alerts
- automated regular backup of code from GitHub
- central buckets for: logging, terraform state, backups, etc.
- CloudTrail (optional)

```
provider "aws" {
  profile = "<project>"
  region = "eu-central-1"
}

provider "aws" {
  alias = "us-east-1"
  profile = "<project>"
  region = "us-east-1"
}

module "stack-global" {
  source = "github.com/dbl-works/terraform//stack/global?ref=v2022.11.27"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1 # Stack module requires us to pass aws.peer to the block
  }

  project = "facebook"

  # optional
  global_accelerator_config = {
    load_balancers = [
      {
        region   = "eu-central-1"
        endpoint = "arn:aws:elasticloadbalancing:eu-central-1:${account_id}:loadbalancer/app/${project}-${environment}/xxx"
        weight   = 128
      },
      {
        region   = "us-east-1"
        endpoint = "arn:aws:elasticloadbalancing:us-east-1:${account_id}:loadbalancer/app/${ecs_name}/xxx"
        weight   = 128
      }
    ]

    # optional
    health_check_path = "/livez"
    health_check_port = 3000
    client_affinity   = "SOURCE_IP"
  }
  sentry_config = {
    facebook = {
      organization_name    = "facebook"
      slack_workspace_name = "Meta"
      platform             = "javascript"
      sentry_teams         = ["developers"]
      frequency            = 30
    }
  }
  period_for_billing_alert = "86400"
  monthly_billing_threshold = "1000"
  sns_topic_name = "slack-sns"
  chatbot_config = {
    slack_channel_id   = "CXXXXXXXXXX"
    slack_workspace_id = "TXXXXXXXX"
  }
  github_backup_config = {
    github_org = "dbl-works"
    interval_value     = 1
    interval_unit      = "hour"
    ruby_major_version = "3"
    timeout            = 900 # Lambda timeout in seconds
    memory_size        = 2048 # Lambda memory in MB
  }
  users = {
    gh-jacky = {
      iam            = string
      github         = string
      name           = string
      groups         = list(string)
      project_access = map(any)
    }
  }
  environment_tags_for_taggable_resources = ["staging", "production"]
  iam_cross_account_config = {
    origin_aws_account_id = "xxxxxxxxxxxxxx"
    aws_role_name = "assume-role-admin"
  }
  is_cloudtrail_log_ingestor = false
  cloudtrail_producer_config = {
    enable_cloudtrail                  = true
    s3_bucket_arns_for_data_cloudtrail = [
      "arn:aws:s3:::bucket_name/important_s3_bucket",
      "arn:aws:s3:::bucket_name/second-important_s3_bucket/prefix",
    ]
    enable_data_cloudtrail             = true
    cloudtrail_target_bucket_name      = [
      "arn:aws:s3:::cloudtrail-bucket",
    ]
    cloudtrail_target_bucket_kms_arn   = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-a123-456a-a12b-a123b4cd56ef"
  }
  private_buckets_list = [{
    bucket_name                     = "someproject-staging-storage"
    versioning                      = true
    primary_storage_class_retention = 0
    kms_deletion_window_in_days     = 30
    region                          = null
    regional                        = false
    replicas = {
      bucket_arn = "arn:aws:s3:::staging-storage-us-east-1"
      kms_arn = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    }
  }]
  ecr_scanner_notifier_config = {
    slack_webhook_url = "https://hooks.slack.com/services/XXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    slack_channel = "ecr-scanner"
  }
}
```
