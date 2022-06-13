resource "aws_ecs_cluster" "main" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = local.name
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "main-ecs-cluster" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]
}
