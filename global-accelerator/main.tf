resource "aws_globalaccelerator_accelerator" "main-accelerator" {
  name            = "${var.project}-${var.environment}"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

# listener for SSL encrypted traffic
resource "aws_globalaccelerator_listener" "main-listener-443" {
  accelerator_arn = aws_globalaccelerator_accelerator.main-accelerator.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

# endpoints for each region for SSL encrypted traffic
resource "aws_globalaccelerator_endpoint_group" "endpoint-group-443" {
  for_each = { for lb in var.load_balancers : lb.region => lb }

  listener_arn          = aws_globalaccelerator_listener.main-listener-443.id
  endpoint_group_region = each.value.region
  health_check_port     = var.health_check_port
  health_check_protocol = "HTTP"
  health_check_path     = var.health_check_path

  endpoint_configuration {
    endpoint_id = each.value.endpoint
  }
}
