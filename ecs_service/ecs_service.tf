data "aws_ecs_cluster" "main" {
  cluster_name = "${var.project}-${var.environment}"
}

data "aws_iam_role" "main" {
  name = "ecs-task-execution-${var.project}-${var.environment}"
}

data "aws_lb_target_group" "ecs" {
  name = "${var.project}-${var.environment}-ecs"
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
  name = "${var.project}-${var.environment}-ecs"
}

output "security_group" {
  value = data.aws_security_group.ecs
}

resource "aws_ecs_service" "main" {
  name            = var.container_name
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.public.ids

    security_groups = [
      data.aws_security_group.ecs.id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.ecs.arn
    container_name   = var.container_name
    container_port   = var.app_container_port
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