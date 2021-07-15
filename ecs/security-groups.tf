# Load balancer to receive all incoming traffic infront of the cluster
resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  name   = "${var.project}-${var.environment}-alb"
  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Description = "Incoming internet traffic to Load Balancer"
    Project     = var.project
    Environment = var.environment
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] # TODO: Change this to internal IPs only
  }
}

resource "aws_security_group_rule" "lb-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}



# ECS cluster should only be able to receive traffic to container ports from the ALB
resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  name   = "${var.project}-${var.environment}-ecs"
  tags = {
    Name        = "${var.project}-${var.environment}-ecs"
    Description = "Internal ECS communication"
    Project     = var.project
    Environment = var.environment
  }

  # This allows outbound traffic to systems like ECR, and internal rails application API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] # TODO: Change this to only allow NAT/proxy traffic
  }
}

# allow traffic from main app to side car services
resource "aws_security_group_rule" "ecs-lb" {
  for_each                 = toset(var.allow_internal_traffic_to_ports)
  type                     = "ingress"
  from_port                = 0
  to_port                  = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.ecs.id
}

# port 3000 is the main entry point for cluster applications
resource "aws_security_group_rule" "ecs-lb-3000" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs-ssh" {
  count             = length(var.allowlisted_ssh_ips) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  cidr_blocks       = var.allowlisted_ssh_ips
}
