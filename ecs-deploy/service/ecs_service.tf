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
    container_port   = length(var.app_config.container_ports) > 0 ? var.app_config.container_ports[0] : null
  }] : []
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "${var.project}-${var.environment}-${var.subnet_type}-*",
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

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker.enable
    rollback = var.deployment_circuit_breaker.rollback
  }

  network_configuration {
    subnets = data.aws_subnets.selected.ids
    security_groups = concat([
      data.aws_security_group.ecs.id
    ], var.security_group_ids)
    assign_public_ip = var.subnet_type == "public"
  }

  dynamic "service_registries" {
    for_each = aws_service_discovery_service.main

    content {
      registry_arn = service_registries.value.arn
      # port, container_name, and container_port are already declared in the task-definition
    }
  }

  # not required if you don't want to use a load balancer, e.g. for Sidekiq
  dynamic "load_balancer" {
    for_each = local.load_balancers

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = length(var.app_config.container_ports) > 0 ? var.app_config.container_ports[0] : null
    }
  }

  deployment_controller { type = "ECS" }

  tags = {
    Name        = var.app_config.name
    Project     = var.project
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      desired_count # We should not care about the desired count after the first deployment
    ]
  }
}


resource "aws_service_discovery_service" "main" {
  count = local.service_discovery_enabled ? 1 : 0

  name = var.app_config.name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10 # time in seconds that DNS resolvers cache the settings for this record
      type = "A"
    }

    routing_policy = "MULTIVALUE" # one of MULTIVALUE or WEIGHTED
  }

  health_check_custom_config {
    failure_threshold = 2 # number between 1 and 10; number of 30 second intervals to wait before declaring failure
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
