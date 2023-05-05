locals {
  name           = "${var.project}-${var.environment}"
  log_group_name = "/kinesis/${local.name}"
}
