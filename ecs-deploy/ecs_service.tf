data "aws_ecs_cluster" "main" {
  cluster_name = local.name
}

data "aws_iam_role" "main" {
  name = "ecs-task-execution-${local.name}"
}

data "aws_lb_target_group" "ecs" {
  name = var.load_balancer_target_group_name == null ? "${local.name}-ecs" : var.load_balancer_target_group_name
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.environment}"]
  }
}

locals {
  # There are 3 possibilities here:
  # 1. Load balancer is needed but no target group arn is passed in => Use the default ecs target group
  # 2. Load balancer is needed and target group arn is passed in => Use the aws_lb_target_group_arn
  # 3. Load balancer is not needed => Don't configure load balancer
  load_balancers = var.with_load_balancer ? [{
    target_group_arn = var.aws_lb_target_group_arn == null ? data.aws_lb_target_group.ecs.arn : var.aws_lb_target_group_arn
    container_name   = var.app_config.name,
    container_port   = var.app_config.container_port
  }] : []
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "${var.project}-${var.environment}-public-*",
    ]
  }
}

data "aws_security_group" "ecs" {
  name = "${local.name}-ecs"
}

resource "aws_ecs_service" "main" {
  name            = var.app_config.name
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.public.ids

    security_groups = [
      data.aws_security_group.ecs.id
    ]
    assign_public_ip = true
  }

  # not required if you don't want to use a load balancer, e.g. for Sidekiq
  dynamic "load_balancer" {
    for_each = local.load_balancers

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  deployment_controller {
    type = "ECS"
  }

  tags = {
    Name        = var.app_config.name
    Project     = var.project
    Environment = var.environment
  }
}
