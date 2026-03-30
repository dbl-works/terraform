# Terraform Module: ECS task

The task definition used for running a task within a cluster.

### Setting up task definition in ECS
```
locals {
  service = "facebook"
  project = "meta"
  environment = "staging"
  secrets = [
    "DATABASE_URL_MASTER",
  ]
  environment_variables = {
    RACK_ENV = local.environment,
    PORT     = "${local.port}",
  }
  image_tag = "latest-main"
  task_list = {
    create_db = {
      command = [
        "bundle",
        "exec",
        "rails",
        "db:create",
      ]
    },
    drop_db = {
      command = [
        "bundle",
        "exec",
        "rails",
        "db:drop",
      ]
    },
  }
}

module "ecs-task" {
  source = "github.com/dbl-works/terraform//aws/ecs-task?ref=main"

  for_each = { for idx, name in keys(local.task_list) :
    idx => {
      name    = name
      command = local.task_list[name].command
    }
  }

  # Required
  environment           = local.environment
  project               = local.project
  name                  = each.value.name
  image_tag             = local.image_tag
  commands              = each.value.command

  # Optional
  ecr_repo_name         = local.service
  image_name            = "facebook/facebook" # Public docker image name
  environment_variables = local.environment_variables
  log_group_name        = "${local.service}-${local.environment}"
  cpu                   = 256
  memory                = 512
  aws_iam_role_name     = "ecs-task-executor"
  ecs_fargate_log_mode  = "non-blocking"
  cloudwatch_logs_retention_in_days = 14
  secrets               = local.secrets
  enable_cloudwatch_log = each.key == "1" # We only create the cloudwatch log group once
  secret_name           = "${local.project}/${local.service}/${local.environment}"
}
```

### CirlceCI
After deploying task definition to ECS, you can run the task in CircleCI using the aws-ecs packages

_NOTE: The run-task step would not check for errors after successful deployment of the task_
```
# .circleci/config.yml

orbs:
  aws-cli: circleci/aws-cli@3.1.4
  aws-ecs: circleci/aws-ecs@3.2

commands:
  run-some_task-staging:
    resource_class: small
    docker:
      - image: cimg/python:3.10
    steps:
      - aws-cli/install
      - aws-ecs/run-task:
          cluster: <project>-<environment>
          security-group-ids: sg-xxx
          subnet-ids: subnet-1, subnet-2, subnet-3
          task-definition: <project>-<environment>-task-<task-name>
          assign-public-ip: ENABLED
```
