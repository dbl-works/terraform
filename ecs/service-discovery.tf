resource "aws_service_discovery_private_dns_namespace" "main" {
  count = var.service_discovery_enabled ? 1 : 0

  name        = "${var.project}-${var.environment}.local"
  vpc         = var.vpc_id
  description = "${var.project}-${var.environment}"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
