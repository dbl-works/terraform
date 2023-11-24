# Terraform Module: ECS Deploy Cluster
Deploy a set of ECS services.

## Usage

```terraform
module "ecs_cluster_services" {
  source = "github.com/dbl-works/terraform//ecs-deploy/cluster?ref=main"

  environment = "staging"
  project     = module.shared.project
  region      = local.region

  services = {
    web = {
      app_config = merge(module.shared.app_config, {
        image_tag             = "latest"
        environment_variables = {
          PORT                = "3000",
          RAILS_MAX_THREADS   = "4",
        }
      })
      cpu                             = 256
      memory                          = 512
    },
    sidekiq = {
      app_config = {
        name                  = "sidekiq"
        image_tag             = "latest"
        ecr_repo_name         = "facebook"
        commands              = ["bundle", "exec", "sidekiq", "--timeout", "8", "--concurrency", "4", "--queue", "default"]
        container_port        = null
        environment_variables = {
          PORT                = "3000",
          RAILS_MAX_THREADS   = "4",
        }
        secrets               = [
          "DATABASE_URL",
          "RAILS_MASTER_KEY",
        ]
      }
      cpu                = 256
      memory             = 512
      with_load_balancer = false
    },
    bastion = {
      app_config                      = {
        name           = "bastion"
        image_tag      = "v1.4"
        image_name     = "dblworks/bastion"
        container_port = 22
        secrets        = []
        commands       = []
        environment_variables = {}
      }
      load_balancer_target_group_name = "${local.project}-${local.environment}-ssh"
      cpu                             = 256
      memory                          = 512
    },
  }
}
```
