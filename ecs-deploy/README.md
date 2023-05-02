# Terraform Module: ECS Deploy

Deploy ECS services with Terraform.

## Usage

```terraform
module "ecs-deploy" {
  source = "github.com/dbl-works/terraform//ecs_service?ref=main"

  project              = local.project
  environment          = local.environment
  ecr_repo_name        = "facebook"
  logger_ecr_repo_name = "facebook-log"

  # Optional
  app_container_port     = 3000 # set to "null" to skip port mapping, necessary e.g. for sidekiq
  app_image_name         = "google/cloud-sdk"
  commands               = ["bundle", "exec", "puma", "-C", "config/puma.rb"]
  container_name         = "web"
  cpu                    = 256
  environment_variables  = {}
  app_image_tag          = "latest-main"
  logger_image_tag       = "latest-main"
  memory                 = 512
  secrets                = []
  logger_secrets         = [] # e.g. tokens for remote services logs are sent to
  secrets_alias          = null # defaults to "${var.project}/app/${var.environment}"
  service_json_file_name = "web_with_logger" # or: "web" for no logging, or "sidekiq_with_logger" for sidekiq
  with_load_balancer     = false

  log_path               = "log"
  logger_container_port  = 4318
  logger_ecr_repo_name   = "logger-private-registry"
  logger_image_name      = "google/logger"
  volume_name            = "log"
  with_logger            = false
  desired_count          = 2
}
```
