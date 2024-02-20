variable "project" {
  type = string
}

variable "environment" {
  type    = string
  default = "global"
}

variable "global_accelerator_config" {
  type = object({
    load_balancers = list(object({
      region   = string
      endpoint = string
      weight   = optional(number, 128)
    }))
    client_affinity   = optional(string, "SOURCE_IP")
    health_check_path = optional(string, "/livez")
    health_check_port = optional(number, 3000)
  })
  default = null
}

variable "sentry_config" {
  type = map(object({
    organization_name    = string
    slack_workspace_name = string
    platform             = optional(string, "ruby-rails")
    sentry_teams         = optional(list(string), null)
    frequency            = optional(number, 30)
  }))
  default = {}
}

variable "period_for_billing_alert" {
  default     = "86400"
  description = "How frequent should we check for the bill (in seconds)"
}

variable "monthly_billing_threshold" {
  default     = "1000"
  description = "The threshold for which estimated monthly charges will trigger the metric alarm. (in USD)"
}

variable "sns_topic_name" {
  default = "slack-sns"
}

variable "chatbot_config" {
  type = object({
    slack_channel_id   = string
    slack_workspace_id = string
  })
  default = null
}

variable "github_backup_config" {
  type = object({
    github_org         = string
    interval_value     = optional(number, 1)
    interval_unit      = optional(string, "hour")
    ruby_major_version = optional(string, "3")
    timeout            = optional(number, 900)
    memory_size        = optional(number, 2048)
  })
  default = null
}

variable "users" {
  type = map(object({
    iam            = string
    github         = string
    name           = string
    groups         = list(string)
    project_access = map(any)
  }))
  default = {}
}

variable "environment_tags_for_taggable_resources" {
  type    = list(string)
  default = ["staging", "production"]
}

variable "iam_cross_account_config" {
  type = object({
    origin_aws_account_id = string
    assume_role_name      = string
  })
  default = null
}

variable "is_cloudtrail_log_ingestor" {
  type    = bool
  default = false
}

variable "cloudtrail_producer_config" {
  type = object({
    enable_cloudtrail                  = optional(bool, true)
    s3_bucket_arns_for_data_cloudtrail = optional(list(string), [])
    enable_data_cloudtrail             = optional(bool, false)
    cloudtrail_target_bucket_name      = optional(string, null)
    cloudtrail_target_bucket_kms_arn   = optional(string, null)
  })
  default = null
}

output "validate_cloudtrail" {
  value = null

  precondition {
    condition     = (var.cloudtrail_producer_config != null || var.is_cloudtrail_log_ingestor)
    error_message = "The account must be configured as either a CloudTrail log producer, with specified target bucket details, or as a CloudTrail log ingestor."
  }
}

variable "private_buckets_list" {
  default = []
  type = set(object({
    bucket_name                     = string
    versioning                      = bool
    primary_storage_class_retention = number
    kms_deletion_window_in_days     = optional(number, 30)
    region                          = optional(string, null)
    regional                        = optional(bool, false)
    replicas = optional(list(object({
      bucket_arn = string
      kms_arn    = string
      region     = string
    })), [])
  }))
  description = "S3 private buckets that are required globally, such as buckets used for storing Terraform state files or centralized log storage."
}

variable "ecr_scanner_notifier_config" {
  type = object({
    slack_webhook_url = string
    slack_channel     = string
  })
  default = null
}

variable "circleci_token_rotator" {
  description = "Rotates the AWS Token for the deploy-bot user in CircleCI"
  default     = null

  type = object({
    context_name    = string
    organization_id = string
  })
}
