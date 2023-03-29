# Terraform Module: ECR Service

Deploy ECS Service

## Usage

```terraform
module "ecs_service" {
  source = "github.com/dbl-works/terraform//ecs_service?ref=main"

  project              = local.project
  environment          = local.environment
  ecr_repo_name        = "facebook"
  logger_ecr_repo_name = "facebook-log"

  # Optional
  image_tag              = "latest-main"
  cpu                    = 256
  memory                 = 512
  container_name         = "web"
  volume_name            = "log"
  service_json_file_name = "web_with_logger" # or: "web" for no logging, or "sidekiq_with_logger" for sidekiq
  logger_container_port  = 4318
  app_container_port     = 3000 # set to "null" to skip port mapping, necessary e.g. for sidekiq
  log_path               = "log"
  environment_variables  = {}
  secrets                = []
  commands               = ["bundle", "exec", "puma", "-C", "config/puma.rb"]
  secrets_alias          = null # defaults to "${var.project}/app/${var.environment}"
}
```
