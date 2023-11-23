# Terraform Module: ECS Deploy

Deploy ECS services with Terraform.

## Usage

```terraform
module "ecs-deploy" {
  source = "github.com/dbl-works/terraform//ecs-deploy/service?ref=main"

  project              = local.project
  environment          = local.environment
  ecr_repo_name        = "facebook"

  # Optional
  cpu                           = 256
  memory                        = 512
  desired_count                 = 2
  with_load_balancer            = true
  ephemeral_storage_size_in_gib = 20   # available disk size for the task, 20-200 GiB

  app_config = {
    name                  = "facebook"
    image_tag             = "v1.0"
    ecr_repo_name         = "facebook"
    commands              = ["node", "index.js"]
    container_port        = 5000
    environment_variables = {}
    secrets               = []
  }

  sidecar_config = [{
    name           = "statsd"
    image_tag      = "v0.10.1"
    image_name     = "statsd/statsd"
    secrets        = []
    container_port = 8125
    protocol       = "udp"
    mount_points   = []
  }]

  aws_lb_target_group_arn = "arn:aws:elasticloadbalancing:eu-central-1:account-id:targetgroup/facebook/xxxxxxxxxxxxxxxx"
}
```
