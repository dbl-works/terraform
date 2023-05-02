locals {
  name = var.cluster_name != null ? var.cluster_name : "${var.project}-${var.environment}${var.regional ? "-${var.region}" : ""}"
}


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
  name            = var.container_name
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
    for_each = var.with_load_balancer ? [{
      target_group_arn = data.aws_lb_target_group.ecs.arn,
      container_name   = var.container_name,
      container_port   = var.app_container_port
    }] : []
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
    Name        = var.container_name
    Project     = var.project
    Environment = var.environment
  }
}
