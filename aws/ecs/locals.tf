data "aws_region" "current" {}

locals {
  region = data.aws_region.current.region
  name   = var.name != null ? var.name : "${var.project}-${var.environment}${var.regional ? "-${local.region}" : ""}"
}
